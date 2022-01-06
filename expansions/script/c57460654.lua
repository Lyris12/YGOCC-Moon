--Nulla Puntodifuoco
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--spsummon self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	--shuffle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(cid.tdcon)
	e2:SetTarget(cid.tdtg)
	e2:SetOperation(cid.tdop)
	c:RegisterEffect(e2)
	--check disabled status
	if not cid.global_check then
		cid.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(cid.registerop)
		Duel.RegisterEffect(ge1,0)
	end
end
--check disabled status
function cid.registerop(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsDisabled),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,nil)
	local d=Duel.GetMatchingGroup(Card.IsDisabled,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,nil)
	if g:GetCount()>0 then
		for tc in aux.Next(g) do
			if tc:GetFlagEffect(id)<=0 then
				tc:RegisterFlagEffect(id,RESET_EVENT+EVENT_CUSTOM+1010101,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
			end
			if tc:GetFlagEffectLabel(id)~=100 then
				tc:SetFlagEffectLabel(id,100)
			end
		end
	end
	if d:GetCount()>0 then
		local reg=Group.CreateGroup()
		for tc2 in aux.Next(d) do
			if tc2:GetFlagEffect(id)<=0 then
				tc2:RegisterFlagEffect(id,RESET_EVENT+EVENT_CUSTOM+1010101,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
			end
			if tc2:GetFlagEffectLabel(id)~=200 then
				reg:AddCard(tc2)
				tc2:SetFlagEffectLabel(id,200)
			end
		end
		if reg:GetCount()>0 then
			Duel.RaiseEvent(reg,EVENT_CUSTOM+id,e,0,0,0,0)
		end
	end
end
--filters
function cid.cfilter(c)	
	return c:IsFaceup() and c:IsSetCard(0x556)
end
function cid.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeckAsCost() and not c:IsDisabled()
end
--spsummon self
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--shuffle
function cid.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function cid.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function cid.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.IsChainDisablable(0) then
		local g=Duel.GetMatchingGroup(cid.tdfilter,tp,0,LOCATION_ONFIELD,nil)
		if g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
			Duel.NegateEffect(0)
			return
		end
	end
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end