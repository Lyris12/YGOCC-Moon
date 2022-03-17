--Ergoriesumante Linkbaciocodice
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FIEND+RACE_CYBERSE),2,2)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--add
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(aux.exccon)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.matfilter(c)
	return c:IsLinkType(TYPE_NORMAL) and c:IsLinkRace(RACE_FAIRY+RACE_BEAST)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if Duel.SelectYesNo(p,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(p,Card.IsAbleToHand,p,LOCATION_DECK,0,1,1,nil)
			if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
				Duel.ConfirmCards(1-p,g)
				--
				local check=false
				for _,ce in ipairs({g:GetFirst():IsHasEffect(EFFECT_NAME_DECLARED)}) do
					if ce and ce.GetLabel and ce:GetLabel()==Duel.GetTurnCount() then
						check=true
						break
					end
				end
				if not check and g:GetFirst():IsAbleToRemove(p,POS_FACEDOWN) then
					Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
				end
				--
				local code=g:GetFirst():GetOriginalCode()
				if code>e:GetLabel() then
					local val=e:GetLabel()*2
					val=val-math.fmod(val,50)
					local lp=Duel.GetLP(p)-val
					if lp<0 then lp=0 end
					Duel.SetLP(p,lp)
				elseif code<e:GetLabel() and Duel.IsExistingMatchingCard(Card.IsFaceup,p,LOCATION_ONFIELD,0,1,nil) then
					getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT}
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_CODE)
					local ac=Duel.AnnounceCard(p,table.unpack(getmetatable(e:GetHandler()).announce_filter))
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FACEUP)
					local sg=Duel.SelectMatchingCard(p,Card.IsFaceup,p,LOCATION_ONFIELD,0,1,1,nil)
					if #sg>0 then
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_CHANGE_CODE)
						e1:SetValue(ac)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
						sg:GetFirst():RegisterEffect(e1)
					end
				end
			end
		end
	end
end
function s.countop(e)
	if e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) then
		e:GetHandler():SetHint(CHINT_NUMBER,e:GetLabel())
	end
	e:Reset()
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if not g then
		e:GetLabelObject():SetLabel(0)
	else
		local ct=g:GetSum(Card.GetOriginalCode)
		e:GetLabelObject():SetLabel(ct)
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(aux.Stringid(id,2))
		e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_SPSUMMON_SUCCESS)
		e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetLabel(ct)
		e0:SetOperation(s.countop)
		c:RegisterEffect(e0)
	end
end

function s.cf(c,e,tp)
	return c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost() and (not (c:IsCode(CARD_ANONYMIZE) or c:IsType(TYPE_FUSION)) or Duel.GetMZoneCount(tp,c)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cf,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cf,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if #g>0 then
		if g:GetFirst():IsCode(CARD_ANONYMIZE) or g:GetFirst():IsType(TYPE_FUSION) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.thf(c)
	return c:IsType(TYPE_ST) and c:IsSetCard(ARCHE_FUSION) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thf,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thf,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIONS) and e:GetLabel()==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) then
		aux.SpecialSummonButBanish(e:GetHandler(),e,tp)
	end
end