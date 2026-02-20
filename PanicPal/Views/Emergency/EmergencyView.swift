import SwiftUI
import SwiftData

struct EmergencyView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \EmergencyContact.sortOrder) private var contacts: [EmergencyContact]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 911 Button
                    Button {
                        callNumber("911")
                    } label: {
                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.title2)
                            Text("Call 911")
                                .font(.title2.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(AppColors.warmCoral)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    
                    // Crisis hotline
                    Button {
                        callNumber("988")
                    } label: {
                        HStack {
                            Image(systemName: "phone.fill")
                            VStack(alignment: .leading) {
                                Text("988 Suicide & Crisis Lifeline")
                                    .font(.headline)
                                Text("Available 24/7")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.deepTeal)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    
                    // Crisis text info
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundStyle(AppColors.deepTeal)
                        Text("Text HOME to 741741")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.deepTeal.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Emergency contacts
                    if !contacts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Emergency Contacts")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(contacts) { contact in
                                Button {
                                    callNumber(contact.phoneNumber)
                                } label: {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(AppColors.deepTeal)
                                        VStack(alignment: .leading) {
                                            Text(contact.name)
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                            Text(contact.phoneNumber)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "phone.circle.fill")
                                            .font(.title)
                                            .foregroundStyle(AppColors.deepTeal)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .black.opacity(0.05), radius: 4)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.top)
            }
            .background(AppColors.safetyWhite)
            .navigationTitle("Emergency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
    
    private func callNumber(_ number: String) {
        let cleaned = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(cleaned)") {
            UIApplication.shared.open(url)
        }
    }
}
