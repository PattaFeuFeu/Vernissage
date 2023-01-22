//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonKit

struct UserProfileHeader: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @State var account: Account
    @State var relationship: Relationship? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                UserAvatar(accountId: account.id, accountAvatar: account.avatar, width: 96, height: 96)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("\(account.statusesCount)")
                        .font(.title3)
                    Text("Posts")
                        .font(.subheadline)
                        .opacity(0.6)
                }
                
                Spacer()
                
                NavigationLink(destination: FollowersView(accountId: account.id)
                    .environmentObject(applicationState)
                ) {
                    VStack(alignment: .center) {
                        Text("\(account.followersCount)")
                            .font(.title3)
                        Text("Followers")
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                }.foregroundColor(.mainTextColor)
                
                Spacer()
                
                NavigationLink(destination: FollowingView(accountId: account.id)
                    .environmentObject(applicationState)
                ) {
                    VStack(alignment: .center) {
                        Text("\(account.followingCount)")
                            .font(.title3)
                        Text("Following")
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                }.foregroundColor(.mainTextColor)
            }
            
            HStack (alignment: .center) {
                VStack(alignment: .leading) {
                    Text(account.displayNameWithoutEmojis)
                        .foregroundColor(.mainTextColor)
                        .font(.footnote)
                        .fontWeight(.bold)
                    Text("@\(account.acct)")
                        .foregroundColor(.lightGrayColor)
                        .font(.footnote)
                }
                
                Spacer()
                
                self.actionButtons()
            }
            
            if let note = account.note, !note.isEmpty {
                HTMLFormattedText(note, withFontSize: 14, andWidth: Int(UIScreen.main.bounds.width) - 16)
                    .padding(.top, -10)
                    .padding(.leading, -4)
            }
            
            Text("Joined \(account.createdAt.toRelative(.isoDateTimeMilliSec))")
                .foregroundColor(.lightGrayColor.opacity(0.5))
                .font(.footnote)
            
        }
        .padding()
    }
    
    @ViewBuilder
    private func actionButtons() -> some View {
        if self.applicationState.accountData?.id != self.account.id {
            ActionButton {
                await onRelationshipButtonTap()
            } label: {
                HStack {
                    Image(systemName: relationship?.following == true ? "person.badge.minus" : "person.badge.plus")
                    Text(relationship?.following == true ? "Unfollow" : (relationship?.followedBy == true ? "Follow back" : "Follow"))
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(relationship?.following == true ? .dangerColor : .accentColor)
            
            Menu (content: {
                if let accountUrl = account.url {
                    Link(destination: accountUrl) {
                        Label("Open link to profile", systemImage: "safari")
                    }
                    
                    ShareLink(item: accountUrl) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                }
                
                Button {
                    Task {
                        await onMuteAccount()
                    }
                } label: {
                    if self.relationship?.muting == true {
                        Label("Unute", systemImage: "message.and.waveform.fill")
                    } else {
                        Label("Mute", systemImage: "message.and.waveform")
                    }
                }
                
                Button {
                    Task {
                        await onBlockAccount()
                    }
                } label: {
                    if self.relationship?.blocking == true {
                        Label("Unblock", systemImage: "hand.raised.fill")
                    } else {
                        Label("Block", systemImage: "hand.raised")
                    }
                }
                
            }, label: {
                Image(systemName: "ellipsis.circle")
            })
            .buttonStyle(.borderedProminent)
            .tint(Color.secondaryLabel)
        }
    }
    
    private func onRelationshipButtonTap() async {
        do {
            if self.relationship?.following == true {
                if let relationship = try await AccountService.shared.unfollow(
                    forAccountId: self.account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            } else {
                if let relationship = try await AccountService.shared.follow(
                    forAccountId: self.account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "Relationship action failed.", showToastr: true)
        }
    }
    
    private func onMuteAccount() async {
        do {
            if self.relationship?.muting == true {
                if let relationship = try await AccountService.shared.unmute(
                    forAccountId: self.account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            } else {
                if let relationship = try await AccountService.shared.mute(
                    forAccountId: self.account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "Muting/unmuting action failed.", showToastr: true)
        }
    }
    
    private func onBlockAccount() async {
        do {
            if self.relationship?.blocking == true {
                if let relationship = try await AccountService.shared.unblock(
                    forAccountId: self.account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            } else {
                if let relationship = try await AccountService.shared.block(
                    forAccountId: self.account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "Block/unblock action failed.", showToastr: true)
        }
    }
}

