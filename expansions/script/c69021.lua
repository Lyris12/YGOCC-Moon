--Automate ID
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),6,2)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.gtg)
	e1:SetOperation(s.gop)
	e1:SetCountLimit(1,id+100)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	e1:SetCountLimit(1,id+200)
	c:RegisterEffect(e3)
end
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
		and re and re:GetHandler():IsSetCard(0x95)
end
function s.thfilter(c)
	return c:IsSetCard(0x6969) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Filter(Card.IsAbleToDeck,nil)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,#g,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Filter(Card.IsAbleToDeck,nil)
	if #g==0 then return end
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if #g==0 then return end
	Duel.BreakEffect()
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,#g,#g,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<=atk
end
function s.handfilter(c)
	return c:IsSetCard(0x6969) and c:IsType(TYPE_MONSTER) and c:IsPublic()
end
function s.gtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.handfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,#g*500) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(#g*500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,#g*500)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return end
	c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=#Duel.GetMatchingGroup(s.handfilter,tp,LOCATION_HAND,0,nil)*500
	local ct=Duel.Recover(p,d,REASON_EFFECT)
	if ct>0 then
		local g=Duel.GetMatchingGroup(s.desfilter,0,LOCATION_MZONE,nil,ct)
		if #g>0 then Duel.BreakEffect() Duel.Destroy(g,REASON_EFFECT,LOCATION_GRAVE) end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and Duel.GetLP(tp)>Duel.GetLP(1-tp)
		and Duel.IsExistingMatchingCard(function(c)
			return c:IsFaceup() and c:IsCode(69010)
		end,tp,LOCATION_SZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)>8000 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(math.max(Duel.GetLP(tp)-8000,0))/2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=math.max(Duel.GetLP(tp)-8000,0)
	Duel.PayLPCost(tp,d)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Damage(p,math.floor(d/2),REASON_EFFECT)
end
