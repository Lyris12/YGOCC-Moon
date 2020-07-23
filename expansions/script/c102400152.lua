--created & coded by Lyris, art from Cardfight!! Vanguard's "Girl Who Crossed the Gap"
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(cid.negcon)
	e2:SetOperation(cid.negop)
	c:RegisterEffect(e2)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0x1c74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function cid.cfilter(c,tp)
	return c:IsSetCard(0x1c74) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay(tp)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetOverlayGroup(tp,1,0):IsExists(cid.filter,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetOverlayGroup(tp,1,0):FilterSelect(tp,cid.filter,1,1,nil,e,tp)
	if #g==0 then return end
	local tc=g:GetFirst():GetOverlayTarget()
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local ag=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if #ag>0 then
		Duel.BreakEffect()
		Duel.Overlay(tc,ag)
	end
end
function cid.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc74) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(id)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) 
		and g and g:IsExists(cid.tfilter,1,e:GetHandler(),tp) and Duel.IsChainDisablable(ev)
end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		if Duel.NegateEffect(ev) then
			Duel.BreakEffect()
			Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		end
	end
end
