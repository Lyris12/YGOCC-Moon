--Chronologist Vault
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(cod.drcost)
	e1:SetTarget(cod.drtg)
	e1:SetOperation(cod.drop)
	c:RegisterEffect(e1)
	--Move Turn Count
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(cod.mtcon)
	e2:SetOperation(cod.mtop)
	c:RegisterEffect(e2)
end

--Draw
function cod.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,nil,0x593) end
	Duel.DiscardHand(tp,Card.IsSetCard,1,1,REASON_COST,nil,0x593)
end
function cod.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cod.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

--Move Turn Count
function cod.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x593)
end
function cod.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cod.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function cod.mtop(e,tp,eg,ep,ev,re,r,rp)
	Duel.MoveTurnCount()
end