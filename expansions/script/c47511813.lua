--Macchina di Recupero Deltaingranaggi
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	c:RegisterEffect(e1)
	--choose effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(65)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCost(aux.LabelCost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.gcheck(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
function s.tdfilter(c,e,tp)
	local ft=Duel.GetMZoneCount(tp,c)
	local g=Duel.Group(s.spfilterlv,tp,LOCATION_DECK,0,nil,e,tp)
	return ft>0 and c:IsFaceup() and c:IsSetCard(0xfa6) and c:IsLevel(7,8) and c:IsAbleToDeck()
		and g:CheckSubGroup(s.gcheck,1,ft,c:GetLevel())
end
function s.spfilterlv(c,e,tp)
	return c:IsSetCard(0xfa6) and c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cfilter(c)
	return c:IsSetCard(0xfa6) and c:IsAbleToDeckAsCost()
end
function s.sgcheck(g,e,tp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,g,e,tp,0)
end
function s.spfilter(c,e,tp,label)
	return c:IsSetCard(0xfa6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (label==0 or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,c))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and s.tdfilter(chkc,e,tp)
	end
	local c=e:GetHandler()
	local costchk=e:GetLabel()==1
	local b1 = not Duel.PlayerHasFlagEffectLabel(tp,id,1) and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	local b2 = not Duel.PlayerHasFlagEffectLabel(tp,id,2) and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetLabel())
	e:SetLabel(0)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(id,tp,0,b1,b2)
	if opt==0 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,1)
		local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif opt==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
		e:SetProperty(0)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,2)
		if costchk then
			local g=Duel.Group(s.cfilter,tp,LOCATION_GRAVE,0,nil)
			local sg=g:SelectSubGroup(tp,s.sgcheck,false,3,3,e,tp)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
			end
		end
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
	Duel.SetTargetParam(opt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain() then return end
	local opt=Duel.GetTargetParam()
	if opt==0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsFaceup() then
			local lv=tc:GetLevel()
			if Duel.ShuffleIntoDeck(tc)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
				local ft=Duel.GetMZoneCount(tp)
				local g=Duel.Group(s.spfilterlv,tp,LOCATION_DECK,0,nil,e,tp)
				Duel.HintMessage(tp,HINTMSG_SPSUMMON)
				local sg=g:SelectSubGroup(tp,s.gcheck,false,1,ft,lv)
				if #sg>0 then
					Duel.BreakEffect()
					Duel.SpecialSummonNegate(e,sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	elseif opt==1 then
		if Duel.Recover(tp,1000,REASON_EFFECT)>0 and Duel.GetMZoneCount(tp)>0 then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,0)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end