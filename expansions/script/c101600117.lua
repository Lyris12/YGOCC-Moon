--Signer Dragon's Duality
--Dualità del Drago Prescelto
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Target 1 Dragon Synchro Monster you control; return it to the Extra Deck, and if you do, Special Summon up to 2 monsters (including 1 "Signer Dragon" monster) from your GY,
	whose total Levels equal the Level of the returned monster, and if you do, for the rest of this turn, your opponent cannot target those monsters with card effects,
	and they cannot be destroyed by your opponent's card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOEXTRA|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--E1
function s.tefilter(c,g,tp,max)
	return c:IsMonster(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:HasLevel() and c:IsAbleToExtra() and g:CheckSubGroup(s.gcheck,1,max,c,c:GetLevel(),tp)
end
function s.gcheck(g,syn,lv,tp)
	return Duel.GetMZoneCount(tp,syn)>=#g and g:GetSum(Card.GetLevel)==lv and g:IsExists(Card.IsSetCard,1,nil,0xcd01)
end
function s.spfilter(c,e,tp)
	return c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.Group(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local max=(Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and 1 or 2
	if chkc then return #g>0 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tefilter(chkc,g,tp,max) end
	if chk==0 then
		return #g>0 and Duel.IsExists(true,s.tefilter,tp,LOCATION_MZONE,0,1,nil,g,tp,max)
	end
	local tg=Duel.Select(HINTMSG_TOEXTRA,true,tp,s.tefilter,tp,LOCATION_MZONE,0,1,1,nil,g,tp,max)
	Duel.SetCardOperationInfo(tg,CATEGORY_TOEXTRA)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local lv=tc:GetLevel()
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) then
			local ft=Duel.GetMZoneCount(tp)
			local g=Duel.Group(aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
			if ft>0 and #g>0 then
				local max=(Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and 1 or 2
				Duel.HintMessage(tp,HINTMSG_SPSUMMON)
				local sg=g:SelectSubGroup(tp,s.gcheck,false,1,math.min(ft,max),nil,lv,tp)
				if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
					local c=e:GetHandler()
					local og=Duel.GetOperatedGroup()
					for tc in aux.Next(og) do
						local e1=Effect.CreateEffect(c)
						e1:SetDescription(STRING_CANNOT_BE_TARGETED_BY_OPPONENT_EFFECT)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_IGNORE_IMMUNE)
						e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
						e1:SetValue(s.tgval)
						e1:SetOwnerPlayer(tp)
						e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
						tc:RegisterEffect(e1)
						local e2=Effect.CreateEffect(c)
						e2:SetDescription(STRING_CANNOT_BE_DESTROYED_BY_OPPONENT_EFFECT)
						e2:SetType(EFFECT_TYPE_SINGLE)
						e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
						e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
						e2:SetValue(aux.indoval)
						e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
						tc:RegisterEffect(e2)
					end
				end
			end
		end
	end
end
function s.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end