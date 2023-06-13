--created & coded by Lyris, art from Shadowverse's "Merciless Voiding"
--Hadokenihilism
local s,id,o=GetID()
if not s.global_check then
	s.global_check=true
	local f=Card.IsHadoken
	function Card.IsHadoken(c) return f and f(c) or c:IsCode(id) end
end
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)%2==0 and Duel.IsChainDisablable(ev)
end
function s.filter(c)
	return c:IsFaceupEx() and c:IsHadoken() and c:IsAbleToDeck()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local rc=re:GetHandler()
	local ct=1
	if rc:IsAbleToDeck() and rc:IsRelateToEffect(re) then
		g:Merge(eg)
		ct=ct+1
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,ct,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateEffect(ev) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil)
	g:Merge(eg)
	if g:FilterCount(Card.IsAbleToDeck,nil)==2 then Duel.SendtoDeck(g,tp,SEQ_DECKBOTTOM,REASON_EFFECT) end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsHadoken,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function s.sfilter(c,e,tp)
	if not c:IsHadoken() then return end
	if c:IsType(TYPE_MONSTER) then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	else return c:IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local g=Group.CreateGroup()
	for i=0,2 do
		local tc=Duel.GetFieldCard(tp,LOCATION_DECK,i)
		for p=0,1 do Duel.ConfirmCards(p,tc,true) end
		g:AddCard(tc)
	end
	local mg=g:Filter(s.sfilter,nil,e,tp)
	if #mg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=mg:Select(tp,1,1,nil):GetFirst()
		Duel.DisableShuffleCheck()
		if sc:IsType(TYPE_MONSTER) then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(1-tp,sc)
		else Duel.SSet(tp,sc) end
		g:RemoveCard(sc)
	end
	for i=1,#g do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,0),SEQ_DECKTOP) end
end
