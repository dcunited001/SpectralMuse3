import simd
import Metal
import ModelIO

class MuseView: MetalView {
    
    // TODO: update to iOS 9.3
    //    var plane = MDLMesh.newPlaneWithDimensions(vector_float2(100.0,100.0), segments: vector_uint2(11,11), geometryType: .Triangles) // allocator?
    var ellipsoid = MDLMesh.newEllipsoidWithRadii([50.0, 30.0, 75.0], radialSegments: 30, verticalSegments: 20, geometryType: .TypeTriangles, inwardNormals: true, hemisphere: false, allocator: nil)  // allocator?
    var icosohedron = MDLMesh.newIcosahedronWithRadius(100.0, inwardNormals: true, allocator: nil) // allocator?
    
    init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        
        renderBlock = {(encoder) in
            // pull mesh data from shapes, insert into buffers
        }
    }
    
}

class MetalRenderer {
    
    var device: MTLDevice?
    var commandQueue: MTLCommandQueue?
    var shaderLibrary: MTLLibrary?
    var depthState: MTLDepthStencilState?
    let kInFlightCommandBuffers = 3
    
    var avaliableResourcesSemaphore: dispatch_semaphore_t
    var mConstantDataBufferIndex: Int
    // this value will cycle from 0 to kInFlightCommandBuffers whenever a display completes ensuring renderer clients
    // can synchronize between kInFlightCommandBuffers count buffers, and thus avoiding a constant buffer from being overwritten between draws
    
    init() {
        mConstantDataBufferIndex = 0
        avaliableResourcesSemaphore = dispatch_semaphore_create(kInFlightCommandBuffers)
    }
    
    deinit {
        for i in 0...self.kInFlightCommandBuffers{
            dispatch_semaphore_signal(avaliableResourcesSemaphore)
        }
    }
    
    func configure(view: MetalView) {
        view.depthPixelFormat = .Depth32Float
        view.colorPixelFormat = MTLPixelFormat.BGRA8Unorm // ?? correct
        view.stencilPixelFormat = MTLPixelFormat.Invalid
        view.sampleCount = 1
        
        guard let viewDevice = view.device else {
            print("Failed retrieving device from view")
            return
        }
        
        device = viewDevice
        commandQueue = device!.newCommandQueue()
        shaderLibrary = device!.newDefaultLibrary()
    }
    
    func encode(renderEncoder: MTLRenderCommandEncoder, encoding: ((MTLRenderCommandEncoder) -> ())?) {
        renderEncoder.setCullMode(.Front)
    }
}

class BaseRenderer: MetalRenderer, MetalViewDelegate {
    var pipelineState: MTLRenderPipelineState?
    var size = CGSize() // TODO: more descriptive name
    var startTime = CFAbsoluteTimeGetCurrent()
    
    var object: MDLMesh?
    var camera = MDLCamera()
    
    var vertexShaderName = "basic_triangle_vertex"
    var fragmentShaderName = "basic_triangle_fragment"
    
    var projectionMatrix:matrix_float4x4
    var projectionBuffer:MTLBuffer?
    var projectionBufferId:Int = 1
    var projectionPointer: UnsafeMutablePointer<Void>?
    
    var rendererDebugGroupName = "Encode BaseRenderer"
    
    deinit {
        //TODO: release mvp
    }
    
    override init() {
        super.init()
        projectionMatrix = camera.projectionMatrix
    }
    
    func prepareMvpPointer() {
        self.projectionPointer = projectionBuffer!.contents()
    }
    
    func prepareMvpBuffer(device: MTLDevice) {
        self.projectionBuffer = device.newBufferWithLength(sizeof(float4x4), options: .CPUCacheModeDefaultCache)
        self.projectionBuffer?.label = "MVP Buffer"
    }
    
    func updateMvpBuffer() {
        projectionMatrix = camera.projectionMatrix
        memcpy(projectionPointer!, &self.projectionMatrix, sizeof(float4x4))
    }
    
    override func configure(view: MetalView) {
        super.configure(view)
        
        // TODO: set up camera
        
//        adjustUniformScale(view)
        prepareMvpBuffer(device!)
        prepareMvpPointer()
        
        guard preparePipelineState(view) else {
            print("Failed creating a compiled pipeline state object!")
            return
        }
    }
    
//    func adjustUniformScale(view: MetalView) {
//        uniformScale *= float4(1.0, Float(view.frame.width / view.frame.height), 1.0, 1.0)
//    }
    
//    func calcMvpMatrix(modelMatrix: float4x4) -> float4x4 {
//        return calcPerspectiveMatrix() * calcProjectionMatrix() * calcUniformMatrix() * modelMatrix
//    }
    
    func preparePipelineState(view: MetalView) -> Bool {
        guard let vertexProgram = shaderLibrary?.newFunctionWithName(vertexShaderName) else {
            print("Couldn't load \(vertexShaderName)")
            return false
        }
        
        guard let fragmentProgram = shaderLibrary?.newFunctionWithName(fragmentShaderName) else {
            print("Couldn't load \(fragmentShaderName)")
            return false
        }
        
        //setup render pipeline descriptor
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        //setup render pipeline state
        do {
            try pipelineState = device!.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch(let err) {
            print("Failed to create pipeline state, error \(err)")
        }
        
        return true
    }
    
    override func encode(renderEncoder: MTLRenderCommandEncoder, encoding: ((MTLRenderCommandEncoder) -> ())?) {
        super.encode(renderEncoder, encoding: encoding)
        renderEncoder.pushDebugGroup(rendererDebugGroupName)
        renderEncoder.setRenderPipelineState(pipelineState!)
        // object!.encode(renderEncoder)
        
        // yeh, it'd make sense if the renderer returned control to the caller to encode objects
        // - but it's difficult to structure that with all the inheritance
        encoding?(renderEncoder)
        
        encodeVertexBuffers(renderEncoder)
        encodeFragmentBuffers(renderEncoder)
        encodeDraw(renderEncoder)
        renderEncoder.endEncoding()
        renderEncoder.popDebugGroup()
    }
    
    func renderObjects(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer, encoding: ((MTLRenderCommandEncoder) -> ())?) {
//        updateMvpMatrix(object!.modelMatrix)
        updateMvpBuffer()
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        self.encode(renderEncoder, encoding: encoding)
        
        commandBuffer.presentDrawable(drawable)
        
        // __block??
        let dispatchSemaphore: dispatch_semaphore_t = avaliableResourcesSemaphore
        
        commandBuffer.addCompletedHandler { (cmdBuffer) in
            dispatch_semaphore_signal(dispatchSemaphore)
        }
        commandBuffer.commit()
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
//        object!.updateModelMatrix()
    }
    
    func encodeVertexBuffers(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setVertexBuffer(projectionBuffer, offset: 0, atIndex: projectionBufferId)
    }
    
    func encodeFragmentBuffers(renderEncoder: MTLRenderCommandEncoder) {
        
    }
    
    func encodeDraw(renderEncoder: MTLRenderCommandEncoder) {
        let vertexCount = 363
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
    }
}

