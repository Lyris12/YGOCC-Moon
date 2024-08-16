--[[
Sceluspecter Reparations
Riparazioni Scelleraspettro
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Send 3 "Sceluspecter" monsters with different names from your hand, Deck, and/or field to the GY; draw 2 cards.
	Also, if you activated this card while you had 5 or more cards in your hand, immediately after this effect resolves, banish 2 random cards from your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DRAW|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,s.cost,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY while you control a face-up "Number" or "Xyz" Xyz Monster: You can banish this card and up to 3 "Sceluspecter" monsters with different names from your GY;
	until the end of the next turn after this effect resolves, negate the effects of all monsters on the field, except those of Xyz Monsters with 3 or more materials.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(s.discon,s.discost,s.distg,s.disop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToGraveAsCost()
end
function s.gcheck(ct)
	return	function(g,e,tp,mg,c)
				if ct-g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<2 then
					return false,true
				end
				local res=g:GetClassCount(Card.GetCode)==#g
				return res, not res
			end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,nil)
	local ct=Duel.GetDeckCount(tp)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,3,3,s.gcheck(ct),0)
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,3,3,s.gcheck(ct),1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(tg,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local hand=Duel.GetHand(tp)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,2) and (not e:IsHasType(EFFECT_TYPE_ACTIVATE) or #hand<5 or hand:IsExists(Card.IsAbleToRemove,2,nil))
	end
	aux.DrawInfo(tp,2)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and #hand>=5 then
		Duel.SetTargetParam(1)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,hand,2,tp,LOCATION_HAND)
	else
		Duel.SetTargetParam(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,2,REASON_EFFECT)
	if Duel.GetTargetParam()==1 then
		aux.ApplyEffectImmediatelyAfterResolution(s.rmop,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,_e)
	local hand=Duel.GetHand(tp)
	if #hand>=2 then
		local rg=hand:RandomSelect(tp,2)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end

--E2
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER,ARCHE_XYZ)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.rmcfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToRemoveAsCost()
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.rmcfilter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then
		return c:IsAbleToRemoveAsCost() and aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheckbrk,0)
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheckbrk,1,tp,HINTMSG_REMOVE)
	tg:AddCard(c)
	Duel.Remove(tg,POS_FACEUP,REASON_COST)
end
function s.disfilter(c)
	return aux.NegateMonsterFilter(c) and not (c:IsType(TYPE_XYZ) and c:GetOverlayCount()>=3)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local g=Duel.Group(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.disable)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.disable(e,c)
	return (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT) and not (c:IsType(TYPE_XYZ) and c:GetOverlayCount()>=3)
end