--Red Infinity

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--apply effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsCode(39311) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.PlayerHasFlagEffect(tp,id) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.Search(sg,tp)
		end
	end
end

function s.filter1(c)
	return c:IsSetCard(0x24f) and c:IsSummonable(true,nil)
end
function s.filter2(c,e,tp)
	return c:IsSetCard(0x24f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,0,b1,b2)
	if opt==0 then
		e:SetCategory(CATEGORY_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif opt==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
	e:SetLabel(opt)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=e:GetLabel()
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.Summon(tp,tc,true,nil)
		end
	elseif opt==1 then
		if Duel.GetMZoneCount(tp)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
