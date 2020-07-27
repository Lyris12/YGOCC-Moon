--created & coded by Lyris, art from Cardfight! Vanguard's "Nightmare Doll, Alice"
local cid,id=GetID()
function cid.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(cid.con1)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(function(e) return e:GetHandler():IsRelateToBattle() end)
	c:RegisterEffect(e3)
	local e1=e3:Clone()
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(function(e,tp,eg,ep) return cid.con1(e,tp,eg,ep) and e:GetHandler():IsSetCard(0x2c74) end)
	e1:SetTarget(cid.tg)
	e1:SetOperation(cid.op)
	c:RegisterEffect(e1)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(function(e) return eg:IsExists(cid.cfilter,1,nil) and e:GetHandler():IsSetCard(0x2c74) end)
	c:RegisterEffect(e4)
end
function cid.con1(e,tp,eg,ep)
	return ep~=tp
end
function cid.cfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0xc74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanOverlay() and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ)
		and Duel.GetOverlayGroup(tp,1,0):IsExists(cid.filter,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,1,1,nil,TYPE_XYZ):GetFirst()
	if not tc then return end
	Duel.Overlay(tc,c)
	if not c:IsLocation(LOCATION_OVERLAY) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetOverlayGroup(tp,1,0):FilterSelect(tp,cid.filter,1,1,nil,e,tp)
	if #g>0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():GetOverlayGroup():IsExists(cid.filter,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(e:GetHandler():GetOverlayGroup():FilterSelect(tp,cid.filter,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
