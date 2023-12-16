--Light-Crusader Crystal Thrower
function c249001231.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,4,2)
	--addown self summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15452043,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c249001231.operation)
	c:RegisterEffect(e1)
	--discard and draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,249001231)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249001231.drcost)
	e1:SetTarget(c249001231.drtg)
	e1:SetOperation(c249001231.drop)
	c:RegisterEffect(e1)
	--addown other summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15452043,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c249001231.condition)
	e3:SetTarget(c249001231.target)
	e3:SetOperation(c249001231.operation)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(249001231,ACTIVITY_SPSUMMON,c249001231.counterfilter)
end
function c249001231.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c249001231.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
function c249001231.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c249001231.cfilter,1,nil,tp)
end
function c249001231.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
function c249001231.desfilter(c)
	return c:IsFaceup() and (c:GetAttack() == 0 or c:GetDefense() == 0)
end
function c249001231.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	g=Duel.GetMatchingGroup(c249001231.desfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function c249001231.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.GetCustomActivityCount(249001231,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c249001231.splimit)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c249001231.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetAttribute()~=ATTRIBUTE_LIGHT
end
function c249001231.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x233)
end
function c249001231.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001231.tgfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c249001231.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,c249001231.tgfilter,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end