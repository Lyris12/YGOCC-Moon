--[[
Monochrome Valkyrie RK6
Valchiria Monocroma RK6
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	--[[Cannot be used as Xyz Material.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: You can detach 1 material from this card; add 1 "Black and White Wave" from your Deck to your hand,
	then you can attach 1 Synchro Monster from your field or GY to this card as material.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetFunctions(aux.XyzSummonedCond,aux.DetachSelfCost(),s.target,s.operation)
	c:RegisterEffect(e1)
	--[[When a card or effect is activated that targets this card you control (Quick Effect): You can detach 1 material from this card;
	negate the activation, and if you do, attach 1 Level 6 or lower Synchro Monster from your Extra Deck to this card as material.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetFunctions(s.discon,aux.DetachSelfCost(),s.distg,s.disop)
	c:RegisterEffect(e2)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_MONOCHROME_VALKYRIE_RK4)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end

--E1
function s.thfilter(c)
	return c:IsCode(CARD_BLACK_AND_WHITE_WAVE) and c:IsAbleToHand()
end
function s.xyzfilter(c,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_SYNCHRO) and c:IsCanOverlay(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g,tp) then
		local c=e:GetHandler()
		if not c:IsRelateToChain() or not c:IsType(TYPE_XYZ) then return end
		local sg=Duel.Group(aux.Necro(s.xyzfilter),tp,LOCATION_MZONE|LOCATION_GRAVE,0,c,tp)
		if #sg>0 and Duel.SelectYesNo(tp,STRING_ASK_ATTACH) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local tg=sg:Select(tp,1,1,nil)
			if #tg>0 then
				Duel.HintSelection(tg)
				tg=tg:Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
				if #tg>0 then
					Duel.BreakEffect()
					Duel.Attach(tg,c)
				end
			end
		end
	end
end

--E2
function s.xyzfilter2(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(6) and c:IsCanOverlay(tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local gp=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return gp and gp:IsContains(c) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToChain(ev) then
			Duel.SendtoGrave(eg,REASON_EFFECT)
		end
		local c=e:GetHandler()
		if not c:IsRelateToChain() or not c:IsType(TYPE_XYZ) then return end
		Duel.HintMessage(tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc and not tc:IsImmuneToEffect(e) then
			Duel.Attach(tc,c)
		end
	end
end