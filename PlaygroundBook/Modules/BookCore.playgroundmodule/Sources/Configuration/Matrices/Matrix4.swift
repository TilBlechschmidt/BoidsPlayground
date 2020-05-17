/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import simd

extension float4x4 {
    static var identity: float4x4 {
        float4x4(diagonal: [1, 1, 1, 1])
    }

    mutating func scale(_ x: Float, y: Float, z: Float) {
        let scalingMatrix = float4x4(diagonal: [x, y, z, 1])
        self = self * scalingMatrix
    }
}

//class Matrix4 {
//    static let numberOfElements = 16
//
//    var glkMatrix: GLKMatrix4
//
////    convenience init() {
////        self.init(GLKMatrix4())
////    }
//
//    init(_ matrix: GLKMatrix4) {
//        glkMatrix = matrix
//    }
//
//    static func makePerspectiveViewAngle(angleRad: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> Matrix4 {
//        return Matrix4(GLKMatrix4MakePerspective(angleRad, aspectRatio, nearZ, farZ))
//    }
//
//    static func degrees(toRad: Float) -> Float {
//        return GLKMathDegreesToRadians(toRad)
//    }
//
//    func raw() -> (Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float) {
//        return glkMatrix.m
//    }
//
//    func rotateAroundX(_ xAngleRad: Float, y yAngleRad: Float, z zAngleRad: Float) {
//        glkMatrix = GLKMatrix4Rotate(glkMatrix, xAngleRad, 1, 0, 0);
//        glkMatrix = GLKMatrix4Rotate(glkMatrix, yAngleRad, 0, 1, 0);
//        glkMatrix = GLKMatrix4Rotate(glkMatrix, zAngleRad, 0, 0, 1);
//    }
//
//    func translate(_ x: Float, y: Float, z: Float) {
//        glkMatrix = GLKMatrix4Translate(glkMatrix, x, y, z);
//    }
//
//    func scale(_ x: Float, y: Float, z: Float) {
//        glkMatrix = GLKMatrix4Scale(glkMatrix, x, y, z);
//    }
//
//    static func *(lhs: Matrix4, rhs: Matrix4) -> Matrix4 {
//        return Matrix4(GLKMatrix4Multiply(lhs.glkMatrix, rhs.glkMatrix))
//    }
//
//    static func +(lhs: Matrix4, rhs: Matrix4) -> Matrix4 {
//        return Matrix4(GLKMatrix4Add(lhs.glkMatrix, rhs.glkMatrix))
//    }
//}
