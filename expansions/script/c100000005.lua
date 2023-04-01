--Esprision Aim
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Target 1 "Esprision" monster you control; if you still control it, destroy 1 monster your opponent controls with ATK less than the targeted monster,
	and if you do, toss a coin and if the result is heads, draw 2 cards.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_COIN|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If this card is added from your Deck to your hand, except by drawing it: You can discard this card; add 1 other "Esprision" card from your GY to your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.DiscardSelfCost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.toss_coin=true

function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xe50) and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,c,c:GetAttack())
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:HasAttack() and c:GetAttack()<atk
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local sg=Duel.Group(s.desfilter,tp,0,LOCATION_MZONE,nil,g:GetFirst():GetAttack())
	Duel.SetCardOperationInfo(sg,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not tc:IsControler(tp) then return end
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local coin=Duel.TossCoin(tp,1)
			if coin==COIN_HEADS then
				Duel.Draw(tp,2,REASON_EFFECT)
			end
		end
	end
end

function s.thfilter(c)
	return c:IsSetCard(0xe50) and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousLocation()&LOCATION_DECK==LOCATION_DECK and c:GetPreviousControler()==tp and not c:IsReason(REASON_DRAW)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
	end
	c:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,aux.ExceptThisCard(e))
	if #g>0 then
		Duel.Search(g,tp)
	end
end