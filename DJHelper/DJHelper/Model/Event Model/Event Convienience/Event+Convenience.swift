//
//  Event+Convenience.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/26/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import CoreData

extension Event {

    @discardableResult
    convenience init(name: String,
                     eventType: String,
                     eventDescription: String?,
                     eventDate: Date,
                     hostID: Int32,
                     imageURL: URL? = nil,
                     notes: String? = "",
                     eventID: Int32?,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        self.init(context: context)
        self.name = name
        self.eventType = eventType
        self.eventDescription = eventDescription
        self.eventDate = eventDate
        self.hostID = hostID
        self.imageURL = imageURL
        self.notes = notes
        if let unwrappedEventID = eventID {
            self.eventID = unwrappedEventID
        }
    }

    //EventRepresentation -> Event
    convenience init?(eventRepresentation: EventRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let eventDateFromString = eventRepresentation.eventDate.dateFromString() else { return nil }
//        ,
//            let imageURL = eventRepresentation.imageURL,
//            let notes = eventRepresentation.notes else { return nil }
//            let eventID = eventRepresentation.eventID else { return nil }

        self.init(name: eventRepresentation.name,
                  eventType: eventRepresentation.eventType,
                  eventDescription: eventRepresentation.eventDescription,
                  eventDate: eventDateFromString,
                  hostID: eventRepresentation.hostID,
                  imageURL: eventRepresentation.imageURL,
                  notes: eventRepresentation.notes,
                  eventID: eventRepresentation.eventID)
    }

    //Event -> EventRepresentation
    var eventAuthorizationRep: EventRepresentation? {
        guard let name = self.name,
            let eventType = self.eventType,
//            let description = self.eventDescription,
            let eventDate = self.eventDate else { return nil }

        return EventRepresentation(name: name,
                                   eventType: eventType,
                                   eventDescription: self.eventDescription,
                                   eventDate: eventDate.jsonStringFromDate(),
                                   hostID: self.hostID,
                                   imageURL: self.imageURL,
                                   notes: self.notes,
                                   eventID: self.eventID)
    }

    //Event -> EventAuthRequest
    var eventAuthRequest: EventAuthRequest? {
        guard let name = self.name,
             let eventType = self.eventType,
//             let description = self.eventDescription,
             let eventDate = self.eventDate else { return nil }

        return EventAuthRequest(name: name,
                                eventType: eventType,
                                eventDescription: self.eventDescription ?? "",
                                eventDate: eventDate,
                                hostID: self.hostID,
                                imageURL: self.imageURL,
                                notes: self.notes)
    }
}
