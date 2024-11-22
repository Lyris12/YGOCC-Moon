--[[
Manaseal Pylon
Traliccio Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_DARK),2)
	--[[If this card is Link Summoned, or when a Trap Card or effect is activated while you control this monster (in which case this is a Quick Effect): You can add 1 "Manaseal" monster from your
	Deck, GY, or banishment to your hand, or if you control "Manaseal Rune Weaving", you can add 1 DARK monster, instead. You cannot Special Summon other monsters during the turn you activate this
	effect, except DARK monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.LinkSummonedCond,
		aux.SSRestrictionCost(aux.Filter(Card.IsAttribute,ATTRIBUTE_DARK),true,nil,id,nil,1),
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	--[[During your opponent's turn (Quick Effect): You can pay half your LP, then target 1 DARK "Number" Xyz Monster you control; attach as many cards from your GY and banishment to that target as
	possible.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCustomCategory(CATEGORY_ATTACH)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(
		aux.TurnPlayerCond(1),
		aux.PayHalfLPCost,
		s.attg,
		s.atop
	)
	c:RegisterEffect(e3)
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP)
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(CARD_MANASEAL_RUNE_WEAVING)
end
function s.thfilter1(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_MANASEAL) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(false,s.thfilter1,tp,LOCATION_DECK|LOCATION_GB,0,1,nil)
			or (Duel.IsExists(false,s.filter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExists(false,s.thfilter2,tp,LOCATION_DECK|LOCATION_GB,0,1,nil))
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GB)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local f=s.thfilter1
	if Duel.IsExists(false,s.filter,tp,LOCATION_ONFIELD,0,1,nil) then
		f=aux.OR(f,s.thfilter2)
	end
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(f),tp,LOCATION_DECK|LOCATION_GB,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end

--E2
function s.xyzfilter(c,e,tp,g)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and g:IsExists(Card.IsCanBeAttachedTo,1,nil,c,e,tp,REASON_EFFECT)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=Duel.Group(aux.TRUE,tp,LOCATION_GB,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc,e,tp,g) end
	if chk==0 then return #g>0 and Duel.IsExists(true,s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,g) end
	local xyzc=Duel.Select(HINTMSG_ATTACHTO,true,tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,g):GetFirst()
	local tg=g:Filter(Card.IsCanBeAttachedTo,nil,xyzc,e,tp,REASON_EFFECT):Filter(Card.IsInGY,nil)
	if #tg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,#tg,1-tp,0)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,g,#g,0,0,xyzc)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_XYZ) and tc:IsSetCard(ARCHE_NUMBER) and tc:IsAttribute(ATTRIBUTE_DARK) and tc:IsControler(tp) then
		local g=Duel.Group(Card.IsCanBeAttachedTo,tp,LOCATION_GB,0,nil,tc,e,tp,REASON_EFFECT)
		if #g>0 then
			Duel.Attach(g,tc,false,e,REASON_EFFECT,tp)
		end
	end
end