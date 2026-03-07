import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contact.name) private var contacts: [Contact]
    
    @State private var showingAddContact = false
    @State private var newName = ""
    @State private var newPhoneNumber = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(contacts) { contact in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .font(.headline)
                            Text(contact.phoneNumber)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if contact.isDefault {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        setDefault(contact: contact)
                    }
                }
                .onDelete(perform: deleteContacts)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddContact = true }) {
                        Label("Add Contact", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                NavigationStack {
                    Form {
                        TextField("Name", text: $newName)
                        TextField("Phone Number", text: $newPhoneNumber)
                            .keyboardType(.phonePad)
                    }
                    .navigationTitle("New Contact")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddContact = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                addContact()
                                showingAddContact = false
                            }
                            .disabled(newName.isEmpty || newPhoneNumber.isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    private func setDefault(contact: Contact) {
        for c in contacts {
            c.isDefault = (c.id == contact.id)
        }
        try? modelContext.save()
    }
    
    private func addContact() {
        let isFirstContact = contacts.isEmpty
        let newContact = Contact(name: newName, phoneNumber: newPhoneNumber, isDefault: isFirstContact)
        modelContext.insert(newContact)
        try? modelContext.save()
        
        newName = ""
        newPhoneNumber = ""
    }
    
    private func deleteContacts(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(contacts[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Contact.self, inMemory: true)
}
