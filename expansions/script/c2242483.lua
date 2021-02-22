--ミューズ パラダイスµ

--scripted by Warspite
function c2242483.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c2242483.activate)
	c:RegisterEffect(e1)
	--select effect
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c2242483.effcon)
	e2:SetTarget(c2242483.efftg)
	e2:SetOperation(c2242483.effop)
	c:RegisterEffect(e2)
end
function c2242483.setfilter(c)
	return c:IsSetCard(0x16a) and c:IsType(TYPE_TRAP+TYPE_SPELL) and not c:IsCode(2242483) and c:IsSSetable()
end
function c2242483.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c2242483.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(2242483,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:Select(tp,1,1,nil)
		Duel.SSet(tp,sg:GetFirst())
	end
end
function c2242483.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x16a) and c:IsControler(tp)
end
function c2242483.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2242483.cfilter,1,nil,tp)
end
function c2242483.tgfilter(c) 
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() 
end
function c2242483.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x16a) and c:IsAbleToHand() 
end
function c2242483.spfilter(c,e,tp)
	return c:IsSetCard(0x16a) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c2242483.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,2242483)==0
	local b2=Duel.IsExistingMatchingCard(c2242483.tgfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetFlagEffect(tp,2242484)==0
	local b3=Duel.IsExistingMatchingCard(c2242483.thfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(c2242483.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetFlagEffect(tp,2242485)==0
	if chk==0 then return b1 or b2 or b3 end
end
function c2242483.effop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,2242483)==0
	local b2=Duel.IsExistingMatchingCard(c2242483.tgfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetFlagEffect(tp,2242484)==0
	local b3=Duel.IsExistingMatchingCard(c2242483.thfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(c2242483.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetFlagEffect(tp,2242485)==0
	local op=0
	if b1 and b2 and b3 then op=Duel.SelectOption(tp,aux.Stringid(2242483,0),aux.Stringid(2242483,1),aux.Stringid(2242483,2))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(2242483,0))
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(2242483,1))+1
	elseif b3 then op=Duel.SelectOption(tp,aux.Stringid(2242483,2))+2
	else return end
	if op==0 then
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,2242483,RESET_PHASE+PHASE_END,0,1)
	elseif op==1 then
		local g=Duel.GetMatchingGroup(c2242483.tgfilter,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
		Duel.RegisterFlagEffect(tp,2242484,RESET_PHASE+PHASE_END,0,1)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c2242483.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,c2242483.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
		Duel.RegisterFlagEffect(tp,2242485,RESET_PHASE+PHASE_END,0,1)
	end
end