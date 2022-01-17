--Antimonio Spektrale
--Scripted by: XGlitchy30
local s,id = GetID()

function s.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x27a) or c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK))
end
function s.attfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil)
	and rc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c:IsRelateToEffect(e) and c:IsCanOverlay() and rc:IsCanOverlay() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.GetMatchingGroup(s.attfilter,tp,LOCATION_MZONE,0,nil):Filter(aux.NOT(Card.IsStatus),nil,STATUS_BATTLE_DESTROYED)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc then
			c:CancelToGrave()
			rc:CancelToGrave()
			Duel.Overlay(tc,Group.FromCards(rc,c))
		end
	end
end

function s.cfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayCount()>0
end
function s.cfilter2(c,tp)
	return s.cfilter(c) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #g>0 then
		g:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
	end
end
function s.thfilter(c)
	return c:IsSetCard(0x27a) and c:IsType(TYPE_ST) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsRelateToEffect(e) and c:IsSSetable() and Duel.SSet(tp,c)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end