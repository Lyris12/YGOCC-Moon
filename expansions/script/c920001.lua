--[[
Curseflame Noble Abira
Nobile Fiammaledetta Abira
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is Normal or Special Summoned: You can take 1 "Curseflame" Spell/Trap from your Deck, and either:
	● Add it to your hand.
	● Send it to the GY, and if you do, place 1 Curseflame Counter on 1 face-up card on the field.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_TOGRAVE|CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--If this card is sent to the GY: You can Tribute 1 face-up card on either field with a Curseflame Counter; Special Summon this card, but banish it when it leaves the field unless the Tributed card had 3 or more Curseflame Counters.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		aux.TributeGlitchyCost(s.cfilter1,1,1,nil,false,true,aux.TRUE,LOCATION_SZONE,LOCATION_SZONE,nil,nil,nil,s.pretribute),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
	aux.EnableGlobalEffectTributeOppoCost()
end
--E1
function s.filter(c,tp)
	return c:IsST() and c:IsSetCard(ARCHE_CURSEFLAME) and (c:IsAbleToHand() or (c:IsAbleToGrave() and (not tp or Duel.IsExists(false,s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c))))
end
function s.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_CURSEFLAME,1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.filter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_CURSEFLAME)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.ForcedSelect(HINTMSG_OPERATECARD,false,tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local b1=tc:IsAbleToHand()
		local b2=tc:IsAbleToGrave() and (not b1 or Duel.IsExists(false,s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil))
		local opt=aux.Option(tp,nil,nil,{b1,STRING_ADD_TO_HAND},{b2,STRING_SEND_TO_GY})
		if opt==0 then
			Duel.Search(tc,tp)
		elseif opt==1 then
			if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsInGY() then
				local sg=Duel.Select(HINTMSG_COUNTER,false,tp,s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
				if #sg>0 then
					Duel.HintSelection(sg)
					sg:GetFirst():AddCounter(COUNTER_CURSEFLAME,1)
				end
			end
		end
	end
end

--E2
function s.cfilter1(c,e,tp)
	return c:IsFaceup() and c:HasCounter(COUNTER_CURSEFLAME) and Duel.GetMZoneCount(tp,c)>0
end
function s.pretribute(rg,e,tp,eg,ep,ev,re,r,rp)
	local tc=rg:GetFirst()
	e:SetLabel(tc:GetCounter(COUNTER_CURSEFLAME))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local val=(e:IsCostChecked() and e:GetLabel()>=3) and 1 or 0
	Duel.SetTargetParam(val)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		if Duel.GetTargetParam()==1 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
