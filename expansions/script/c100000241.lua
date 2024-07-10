--[[
Automatyrant Clockwork Dragon
Automatiranno Drago a Orologeria
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your Main Phase: You can banish 1 Spell and 1 Trap from your GY; Special Summon this card from your hand or GY, and if you do, send the top 5 cards of your Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(aux.MainPhaseCond(0),s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can target up to 3 appropriate Union monsters in your GY; equip them to this card,
	but the Union monsters you equipped cannot be Special Summoned this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.eqtg,s.eqop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[While this card is equipped with 2 or more Equip Cards, your opponent cannot target it with card effects.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tgcond)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
s.has_text_type=TYPE_UNION

--E1
function s.cfilter(c)
	return c:IsST() and c:IsAbleToRemoveAsCost()
end
function s.gcheck(g,e,tp,mg,c)
	if #g==1 then
		return true
	else
		local tc1,tc2=g:GetFirst(),g:GetNext()
		local res=tc1:IsSpell() and tc2:IsTrap()
		if not res then
			tc1,tc2=tc2,tc1
			res=tc1:IsSpell() and tc2:IsTrap()
		end
		return res
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.cfilter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,1,tp,HINTMSG_REMOVE,s.gcheck)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsPlayerCanDiscardDeck(tp,5) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.DiscardDeck(tp,5,REASON_EFFECT)
	end
end

--E2
function s.unionfilter(c,tc,tp,e)
	return c:IsCanBeEffectTarget(e) and aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.oldunion(c)
	return c.old_union
end
function s.unionchk(g,e,tp,mg,c)
	return #g==1 or not g:IsExists(s.oldunion,1,nil), c and #g>1 and c.old_union
end
function s.breakcon(g,e,tp,mg)
	return g:IsExists(s.oldunion,1,nil)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.Group(s.unionfilter,tp,LOCATION_GRAVE,0,nil,c,tp,e)
	if chk==0 then
		return ft>0 and #g>0
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,math.min(3,ft),s.unionchk,1,tp,HINTMSG_TARGET,s.unionchk,s.breakcon)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_EQUIP)
	Duel.SetCardOperationInfo(tg,CATEGORY_LEAVE_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards()
	if #g==0 or not c:IsRelateToChain() or not c:IsFaceup() then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft>0 and ft<#g then
		Duel.HintMessage(tp,HINTMSG_EQUIP)
		g=g:Select(tp,ft,ft,nil)
		Duel.HintSelection(g)
	end
	for tc in aux.Next(g) do
		if Duel.Equip(tp,tc,c,true,true) then
			aux.SetUnionState(tc)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_CANNOT_BE_SPECIAL_SUMMONED)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1,true)
		end
	end
	Duel.EquipComplete()
end

--E3
function s.tgcond(e)
	return e:GetHandler():GetEquipCount()>1
end