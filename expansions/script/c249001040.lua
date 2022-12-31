--Photon Treasure
function c249001040.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,249001040)
	e1:SetCost(c249001040.cost)
	e1:SetTarget(c249001040.target)
	e1:SetOperation(c249001040.activate)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,249001040)
	e2:SetCondition(c249001040.drcon)
	e2:SetCost(c249001040.drcost)
	e2:SetTarget(c249001040.drtg)
	e2:SetOperation(c249001040.activate)
	c:RegisterEffect(e2)
end
function c249001040.filter(c)
	return (c:IsSetCard(0x55) or c:IsSetCard(0x7B)) and c:IsDiscardable()
end
function c249001040.cost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(c249001040.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c249001040.filter,1,1,REASON_COST+REASON_DISCARD)
end
function c249001040.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c249001040.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c249001040.cfilter(c,tp)
	return c:IsFaceup() and c:GetSummonPlayer()==tp and (c:IsSetCard(0x55) or c:IsSetCard(0x7B)) and c:IsType(TYPE_XYZ)
end
function c249001040.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c249001040.cfilter,1,nil,tp)
end
function c249001040.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c249001040.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end