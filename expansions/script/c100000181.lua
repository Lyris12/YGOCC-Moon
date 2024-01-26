--[[
Lord of the Silver Tower
Signore della Torre d'Argento
Card Author: LeonDuvall
Rescripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) while you control a Field Spell by sending 1 "Truesilver" Equip Spell from your Deck to the GY.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT(true)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is Normal or Special Summoned while you control a Field Spell: You can equip 1 "Truesilver" Equip Spell from your hand or GY to it.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[If an Equip Spell you control equipped to this card would be destroyed, you can banish 1 Equip Spell from your GY instead.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
--E1
function s.tgfilter(c)
	return c:IsSpell(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpell,TYPE_FIELD),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end

--E2
function s.eqfilter(c,ec,tp)
	return c:IsSetCard(ARCHE_TRUESILVER) and c:IsSpell(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpell,TYPE_FIELD),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e:GetHandler(),tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToChain() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,c,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.Equip(tp,tc,c)
	end
end

--E3
function s.repfilter(c,tp,hc)
	if not (c:IsFaceup() and c:IsControler(tp) and c:IsSpell(TYPE_EQUIP) and not c:IsReason(REASON_REPLACE)) then return false end
	local ec=c:GetEquipTarget()
	return ec and ec==hc 
end
function s.rmfilter(c)
	return c:IsSpell(TYPE_EQUIP) and c:IsAbleToRemove()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return eg:IsExists(s.repfilter,1,nil,tp,c) and Duel.IsExistingMatchingCard(aux.Necro(s.rmfilter),tp,LOCATION_GRAVE,0,1,nil)
	end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,aux.Necro(s.rmfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer(),e:GetHandler())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
	end
end