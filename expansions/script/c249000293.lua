--Rites-Summoner Green Mage
function c249000293.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetCondition(c249000293.condition)
	e2:SetCost(c249000293.cost)
	e2:SetTarget(c249000293.target)
	e2:SetOperation(c249000293.operation)
	c:RegisterEffect(e2)
	--cannot be target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c249000293.etarget)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
function c249000293.confilter(c,e,tp)
	return c:IsSetCard(0x1B0) and not c:IsCode(249000293)
end
function c249000293.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249000293.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c249000293.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c249000293.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249000293.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c249000293.etarget(e,c)
	return c:GetTurnID()==Duel.GetTurnCount() and (c:IsSetCard(0x1AF) or c:IsSetCard(0x1B0))
end