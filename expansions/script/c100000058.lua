--[[
Safety, Deep in the Dreary Forest's Lies
Sicurezza, nel Profondo delle Bugie della Foresta Tetra
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your opponent's turn, when your opponent activates a card or effect while you control a "Dreary Forest" monster:
	Send 1 other card from your hand or field to the GY; negate the activation, and if you do, banish that card.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetFunctions(
		s.condition,
		aux.ToGraveCost(s.cfilter,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,true),
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If a "Dreamy Forest" or "Dreary Forest" monster you control would be destroyed by battle or card effect, you can banish this card from your GY instead.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
--E1
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DREARY_FOREST)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and ep==1-tp and Duel.IsChainNegatable(ev) and Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToChain(ev)
	if chk==0 then
		return rc:IsAbleToRemove(tp) or (not relation and Duel.IsPlayerCanRemove(tp))
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

--E2
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT|REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end