--[[
Curseflame Noble Diras
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	aux.AddCodeList(c,id)
	--You cannot Pendulum Summon monsters, except "Curseflame" monsters. This effect is negated while there are 6 or more Curseflame Counters on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.pspcon)
	e1:SetTarget(s.psplimit)
	c:RegisterEffect(e1)
	--When this card is activated: You can target 1 "Curseflame" Continuous Spell/Trap in your GY; replace this effect with that card's effects.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e2)
	--[[If this card is face-up in your Extra Deck, except during the turn it was sent there: You can either discard 1 card OR remove 3 Curseflame Counters from anywhere on the field; Special Summon
	this card, but banish it when it leaves the field.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_EXTRA)
	e3:HOPT()
	e3:SetFunctions(aux.exccon,s.spcost,xgl.SpecialSummonSelfTarget(),xgl.SpecialSummonSelfOperation(LOCATION_REMOVED))
	c:RegisterEffect(e3)
	--[[If this card is Normal or Special Summoned: You can add 1 "Curseflame" card from your Deck or GY to your hand, except "Curseflame Noble Diras".]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetCategory(CATEGORIES_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:HOPT()
	e4:SetSearchFunctions(s.thfilter,LOCATION_DECK|LOCATION_GRAVE)
	c:RegisterEffect(e4)
	e4:SpecialSummonEventClone(c)
	--[[During the Main Phase, if you control a Level/Rank/Future 5 or higher "Curseflame" monster or a Link-4 or higher "Curseflame" Link Monster (Quick Effect): You can Tribute this card; place 1
	Curseflame Counter on each face-up card on the field.]]
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(id,3)
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:HOPT()
	e5:SetHintTiming(TIMING_MAIN_END)
	e5:SetFunctions(s.ctcon,aux.TributeSelfCost,s.cttg,s.ctop)
	c:RegisterEffect(e5)
end
--E1
function s.pspcon(e)
	return Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)<6
end
function s.psplimit(e,c,tp,sumtp,sumpos)
	return (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsSetCard(ARCHE_CURSEFLAME)
end

--E2
function s.cpfilter(c)
	return c:IsST(TYPE_CONTINUOUS) and c:IsSetCard(ARCHE_CURSEFLAME)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.cpfilter(chkc) end
	if chk==0 then return true end
	if not Duel.PlayerHasFlagEffect(tp,id) and Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,STRING_ASK_TARGET) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and c:IsFaceup() and c:IsRelateToChain() then
		local code=tc:GetOriginalCode()
		c:CopyEffect(code,RESET_EVENT|RESETS_STANDARD)
		if code==920017 or code==920019 then
			local op=tc:GetActivateEffect():GetOperation()
			op(e,tp,eg,ep,ev,re,r,rp)
		end
		c:SetHint(CHINT_CARD,code)
	end
end

--E3
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExists(false,Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.IsCanRemoveCounter(tp,1,1,COUNTER_CURSEFLAME,3,REASON_COST)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,nil,nil,{b1,STRING_DISCARD},{b2,STRING_REMOVE_COUNTER})
	if opt==0 then
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_DISCARD|REASON_COST)
	elseif opt==1 then
		Duel.RemoveCounter(tp,1,1,COUNTER_CURSEFLAME,3,REASON_COST)
	end
end

--E4
function s.thfilter(c)
	return c:IsSetCard(ARCHE_CURSEFLAME) and not c:IsCode(id)
end

--E5
function s.cfilter(c)
	if not (c:IsFaceup() and c:IsSetCard(ARCHE_CURSEFLAME)) then return false end
	local ct,ctype=c:GetRatingAuto()
	if ctype==TYPE_LINK then
		return ct>=4
	else
		return ct>=5
	end
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_CURSEFLAME,1)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then
		local c=e:GetHandler()
		if g:IsContains(c) and e:IsCostChecked() then
			g:RemoveCard(c)
		end
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,COUNTER_CURSEFLAME)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_CURSEFLAME,1)
	end
end