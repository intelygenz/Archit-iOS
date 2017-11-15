//
//  NetContentType.swift
//  Net
//
//  Created by Alex Rupérez on 23/3/17.
//
//

import Foundation

public enum NetContentType {
    case aac, avi, bin, bmp, csv, form, formURL, gif, html, ico, ics, jpeg, js, json, mpeg, mpkg, ogx, pdf, pkcs7, plist, png, rar, rtf, svg, tar, tiff, ttf, txt, wav, weba, webm, webp, wildcard, xhtml, xml, zip, custom(String)
}

extension NetContentType: RawRepresentable {

    private struct StringValue {
        static let aac = "audio/aac"
        static let avi = "video/x-msvideo"
        static let bin = "application/octet-stream"
        static let bmp = "image/bmp"
        static let csv = "text/csv"
        static let form = "multipart/form-data"
        static let formURL = "application/x-www-form-urlencoded"
        static let gif = "image/gif"
        static let html = "text/html"
        static let ico = "image/x-icon"
        static let ics = "text/calendar"
        static let jpeg = "image/jpeg"
        static let js = "application/javascript"
        static let json = "application/json"
        static let mpeg = "video/mpeg"
        static let mpkg = "application/vnd.apple.installer+xml"
        static let ogx = "application/ogg"
        static let pdf = "application/pdf"
        static let pkcs7 = "application/pkcs7-mime"
        static let plist = "application/x-plist"
        static let png = "image/png"
        static let rar = "application/x-rar-compressed"
        static let rtf = "application/rtf"
        static let svg = "image/svg+xml"
        static let tar = "application/x-tar"
        static let tiff = "image/tiff"
        static let ttf = "font/ttf"
        static let txt = "text/plain"
        static let wav = "audio/x-wav"
        static let weba = "audio/webm"
        static let webm = "video/webm"
        static let webp = "image/webp"
        static let wildcard = "*/*"
        static let xhtml = "application/xhtml+xml"
        static let xml = "application/xml"
        static let zip = "application/zip"
    }

    public typealias RawValue = String

    public init(rawValue: RawValue) {
        switch rawValue {
            case StringValue.aac: self = .aac
            case StringValue.avi: self = .avi
            case StringValue.bin: self = .bin
            case StringValue.bmp: self = .bmp
            case StringValue.csv: self = .csv
            case StringValue.form: self = .form
            case StringValue.formURL: self = .formURL
            case StringValue.gif: self = .gif
            case StringValue.html: self = .html
            case StringValue.ico: self = .ico
            case StringValue.ics: self = .ics
            case StringValue.jpeg: self = .jpeg
            case StringValue.js: self = .js
            case StringValue.json: self = .json
            case StringValue.mpeg: self = .mpeg
            case StringValue.mpkg: self = .mpkg
            case StringValue.ogx: self = .ogx
            case StringValue.pdf: self = .pdf
            case StringValue.pkcs7: self = .pkcs7
            case StringValue.plist: self = .plist
            case StringValue.png: self = .png
            case StringValue.rar: self = .rar
            case StringValue.rtf: self = .rtf
            case StringValue.svg: self = .svg
            case StringValue.tar: self = .tar
            case StringValue.tiff: self = .tiff
            case StringValue.ttf: self = .ttf
            case StringValue.txt: self = .txt
            case StringValue.wav: self = .wav
            case StringValue.weba: self = .weba
            case StringValue.webm: self = .webm
            case StringValue.webp: self = .webp
            case StringValue.wildcard: self = .wildcard
            case StringValue.xhtml: self = .xhtml
            case StringValue.xml: self = .xml
            case StringValue.zip: self = .zip
            default: self = .custom(rawValue)
        }
    }

    public var rawValue: RawValue {
        switch self {
            case .aac: return StringValue.aac
            case .avi: return StringValue.avi
            case .bin: return StringValue.bin
            case .bmp: return StringValue.bmp
            case .csv: return StringValue.csv
            case .form: return StringValue.form
            case .formURL: return StringValue.formURL
            case .gif: return StringValue.gif
            case .html: return StringValue.html
            case .ico: return StringValue.ico
            case .ics: return StringValue.ics
            case .jpeg: return StringValue.jpeg
            case .js: return StringValue.js
            case .json: return StringValue.json
            case .mpeg: return StringValue.mpeg
            case .mpkg: return StringValue.mpkg
            case .ogx: return StringValue.ogx
            case .pdf: return StringValue.pdf
            case .pkcs7: return StringValue.pkcs7
            case .plist: return StringValue.plist
            case .png: return StringValue.png
            case .rar: return StringValue.rar
            case .rtf: return StringValue.rtf
            case .svg: return StringValue.svg
            case .tar: return StringValue.tar
            case .tiff: return StringValue.tiff
            case .ttf: return StringValue.ttf
            case .txt: return StringValue.txt
            case .wav: return StringValue.wav
            case .weba: return StringValue.weba
            case .webm: return StringValue.webm
            case .webp: return StringValue.webp
            case .wildcard: return StringValue.wildcard
            case .xhtml: return StringValue.xhtml
            case .xml: return StringValue.xml
            case .zip: return StringValue.zip
            case .custom(let contentType): return contentType
        }
    }

}
