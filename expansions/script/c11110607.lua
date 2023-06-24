--Metalurgos Report
--Rapporto Metalurgo
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Destroy 1 "Metalurgos" card in your Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.drawcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(aux.DrawTarget())
	e2:SetOperation(aux.DrawOperation())
	c:RegisterEffect(e2)
end
--FILTERS E1
function s.desfilter(c,e)
	return c:IsSetCard(ARCHE_METALURGOS) and c:IsDestructable(e)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_DECK,0,1,nil,e)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.desfilter,tp,LOCATION_DECK,0,1,1,nil,e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--FILTERS E2
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(ARCHE_METALURGOS) and c:IsMonster(TYPE_BIGBANG)
end
--E2
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end