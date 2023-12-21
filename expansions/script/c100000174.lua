--[[
Lotus Blade Mimicry
Mimica della Lama di Loto
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Target 1 "Lotus Blade" Continuous Spell in your GY, or that is banished; this effect becomes that card's effect when it is activated, also shuffle that card into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY: You can shuffle this card into the Deck, then target 1 of your "Lotus Blade" monsters that is banished, or in your GY; add it to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,aux.ToDeckSelfCost,s.thtg,s.thop)
	c:RegisterEffect(e2)
end
--E1
function s.filter(c)
	if not (c:IsFaceupEx() and c:IsSpell(TYPE_CONTINUOUS) and c:IsSetCard(ARCHE_LOTUS_BLADE) and c:IsAbleToDeck()) then return false end
	Duel.RegisterFlagEffect(tp,CARD_LOTUS_BLADE_MIMICRY,0,0,1)
	local res=c:CheckActivateEffect(false,true,false)~=nil
	Duel.ResetFlagEffect(tp,CARD_LOTUS_BLADE_MIMICRY)
	return res
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GB,LOCATION_REMOVED,1,nil) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GB,LOCATION_REMOVED,1,1,nil)
	Duel.RegisterFlagEffect(tp,CARD_LOTUS_BLADE_MIMICRY,0,0,1)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	Duel.ResetFlagEffect(tp,CARD_LOTUS_BLADE_MIMICRY)
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local tc=te:GetHandler()
	if not tc:IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		Duel.RegisterFlagEffect(tp,CARD_LOTUS_BLADE_MIMICRY,0,0,1)
		op(e,tp,eg,ep,ev,re,r,rp)
		Duel.ResetFlagEffect(tp,CARD_LOTUS_BLADE_MIMICRY)
	end
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--E2
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_LOTUS_BLADE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GB,0,1,nil)
	end
	Duel.HintMessage(tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GB,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Search(tc,tp)
	end
end