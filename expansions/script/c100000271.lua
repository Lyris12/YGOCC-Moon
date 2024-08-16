--[[
Sceluspecter Vain Foolishness
Vanesia Follia Scelleraspettro
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Your opponent must destroy all monsters they control with cards equipped to them, and if they do, inflict 500 damage to your opponent for each monster destroyed this way.
	If there are at least 3 monsters on the field with "Sceluspecter" monsters equipped to them, your opponent must banish face-down instead of destroying.
	There must be at least 1 "Sceluspecter" monster on the field for you to activate and resolve this effect.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY: Apply 1 of the following effects.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES|CATEGORY_REMOVE|CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,aux.bfgcost,s.applytg,s.applyop)
	c:RegisterEffect(e2)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_SCELUSPECTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.rmchkfilter(c)
	local g=c:GetEquipGroup()
	return g and g:IsExists(s.eqcfilter,1,nil)
end
function s.eqcfilter(c)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(ARCHE_SCELUSPECTER)
end
function s.filter(c,rmcheck,p)
	return s.rmchkfilter(c) and (not rmcheck or c:IsAbleToRemove(p,POS_FACEDOWN,REASON_RULE))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rmcheck=Duel.IsExists(false,s.rmchkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,3,nil)
	if chk==0 then
		return Duel.IsExists(false,s.filter,tp,0,LOCATION_MZONE,1,nil,rmcheck,1-tp)
	end
	local dg=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil,rmcheck,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#dg*500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not s.condition(e,tp,eg,ep,ev,re,r,rp) then return end
	local rmcheck=Duel.IsExists(false,s.rmchkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,3,nil)
	local dg=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil,rmcheck,1-tp)
	if #dg>0 then
		local ct=0
		if rmcheck then
			Duel.Remove(dg,POS_FACEDOWN,REASON_RULE,1-tp)
		else
			Duel.Destroy(dg,REASON_RULE,LOCATION_GRAVE,1-tp)
		end
		local ct=Duel.GetGroupOperatedByThisRule(e):GetCount()
		if ct>0 then
			Duel.Damage(1-tp,ct*500,REASON_EFFECT)
		end
	end
end

--E2
function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToGrave()
end
function s.rtgfilter(c,e,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToReturnToGrave(e,tp,REASON_EFFECT)
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToRemove()
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g1=Duel.Group(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
		local b1=aux.SelectUnselectGroup(g1,e,tp,3,3,aux.ogdncheckbrk,0)
		if b1 then return true end
		
		local g2=Duel.Group(s.rtgfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
		local b2=#g2>0
		if b2 then return true end
		
		local g3=Duel.Group(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
		local b3=#g3>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		if b3 then return true end
		
		return false
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.Group(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
	local g2=Duel.Group(s.rtgfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	local g3=Duel.Group(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	
	local b1=aux.SelectUnselectGroup(g1,e,tp,3,3,aux.ogdncheckbrk,0)
	local b2=#g2>0
	local b3=#g3>0 and ct>0
	if not b1 and not b2 and not b3 then return end
	
	local opt=aux.Option(tp,id,2,b1,b2,b3)
	if not opt then return end
	
	if opt==0 then
		--[[Send 3 "Sceluspecter" monsters with different original names from your hand and/or Deck to the GY.]]
		local tg=aux.SelectUnselectGroup(g1,e,tp,3,3,aux.ogdncheckbrk,1,tp,HINTMSG_TOGRAVE)
		if #tg==3 then
			Duel.ConfirmCards(1-tp,tg)
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	
	elseif opt==1 then
		--[[Return as many of your banished "Sceluspecter" monsters to the GY as possible.]]
		Duel.SendtoGrave(g2,REASON_EFFECT|REASON_RETURN)
	
	elseif opt==2 then
		--[[Banish as many "Sceluspecter" monsters with different original names from your GY as possible, up to the number of monster your opponent controls.]]
		local max=math.min(g3:GetClassCount(Card.GetOriginalCodeRule),ct)
		local rg=aux.SelectUnselectGroup(g3,e,tp,max,max,aux.ogdncheckbrk,1,tp,HINTMSG_REMOVE)
		if #rg>0 then
			Duel.HintSelection(rg)
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end