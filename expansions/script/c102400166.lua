--created & coded by Lyris, art by whoalisaa of DeviantArt
--贅沢
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetCondition(function() return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity() end)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.filter(c,tp)
	return c:GetSequence()<20 and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>24 and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK,0,20,nil,tp)
		or Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,20,nil) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g1,g2=Duel.GetMatchingGroup(cid.filter,p,LOCATION_DECK,0,nil,p),Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local b1,b2=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>21 and #g1>19,#g2>19
	if not b1 and not b2 then return end
	if b2 and (not b1 or Duel.SelectOption(tp,1192,1105)~=0) then
		if Duel.SendtoDeck(g2:Select(p,20,20,nil),nil,2,REASON_EFFECT)==0 or not g2:IsExists(Card.IsLocation,20,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
		Duel.ShuffleDeck(p)
	else
		Duel.DisableShuffleCheck()
		if Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)==0 then return end
	end
	Duel.BreakEffect()
	Duel.ConfirmDecktop(p,5)
	local g=Duel.GetDecktopGroup(p,5)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
	local sg=g:Select(p,2,2,nil)
	Duel.DisableShuffleCheck()
	Duel.SendtoHand(sg:Filter(Card.IsAbleToHand,nil),nil,REASON_EFFECT)
	Duel.SendtoGrave(sg:Filter(aux.NOT(Card.IsAbleToHand),nil),REASON_RULE)
	local hg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #hg>0 then
		Duel.ConfirmCards(1-p,hg)
		Duel.ShuffleHand(p)
	end
	Duel.SortDecktop(p,p,3)
	for i=1,3 do
		Duel.MoveSequence(Duel.GetDecktopGroup(p,1):GetFirst(),1)
	end
end
