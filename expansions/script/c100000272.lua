--[[
Sceluspecter Curse of Decay
Maledizione della Decomposizione Scelleraspettro
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--[[If you control a DARK "Number" Xyz Monster: Attach all monsters your opponent controls that have "Sceluspecter" Monster Cards equipped to them to 1 DARK "Number" Xyz Monster you control,
	and if you do, if 3 or more monsters are attached to an Xyz Monster this way, your opponent takes 2000 damage.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY; add 1 "Rank-Up-Magic" Spell from your Deck or GY to your hand, and if you do, send 2 "Sceluspecter" monsters with different names from your hand and/or Deck to the GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,aux.bfgcost,s.thtg,s.thop)
	c:RegisterEffect(e2)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c,e,tp)
	local g=c:GetEquipGroup()
	return g and g:IsExists(s.eqcfilter,1,nil) and Duel.IsExists(false,s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,e,tp)
end
function s.eqcfilter(c)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(ARCHE_SCELUSPECTER)
end
function s.xyzfilter(c,oc,e,tp)
	return s.cfilter(c) and oc:IsCanBeAttachedTo(c,e,tp,REASON_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.filter,tp,0,LOCATION_MZONE,1,nil,e,tp)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil,e,tp)
	local xyzg=Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local tg=Group.CreateGroup()
	for xyzc in aux.Next(xyzg) do
		if g:IsExists(Card.IsCanBeAttachedTo,1,nil,xyzc,e,tp,REASON_EFFECT) then
			tg:AddCard(xyzc)
		end
	end
	if #tg<=0 then return end
	Duel.HintMessage(tp,HINTMSG_ATTACHTO)
	local tg2=tg:Select(tp,1,1,nil)
	Duel.HintSelection(tg2)
	local xyzc=tg2:GetFirst()
	local matg=g:Filter(Card.IsCanBeAttachedTo,nil,xyzc,e,tp,REASON_EFFECT)
	if #matg>0 and Duel.Attach(matg,xyzc,false,e,REASON_EFFECT,tp)>=3 then
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end

--E2
function s.thfilter(c)
	return c:IsSpell() and c:IsSetCard(ARCHE_RUM) and c:IsAbleToHand()
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToGrave()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) then return false end
		local g=Duel.Group(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheckbrk,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g1>0 and Duel.SearchAndCheck(g1) then
		local g2=Duel.Group(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
		if #g2<=0 then return end
		local tg=aux.SelectUnselectGroup(g2,e,tp,2,2,aux.dncheckbrk,1,tp,HINTMSG_TOGRAVE)
		if #tg>0 then
			Duel.ShuffleHand(tp)
			Duel.ConfirmCards(1-tp,tg)
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	end
end