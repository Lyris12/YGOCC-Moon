--MMS - Monotono Mostruoso Scavo
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	c:Activate(nil,nil,EFFECT_FLAG_CARD_TARGET,nil,nil,
		nil,
		nil,
		s.target,
		s.activate,
		nil,
		RELEVANT_TIMINGS
	)
	--control
	c:Quick(false,1,CATEGORY_CONTROL,nil,nil,LOCATION_SZONE,1,
		aux.LocationGroupCond(s.filter1,LOCATION_MZONE,0,1),
		nil,
		s.cttg,
		s.ctop,
		RELEVANT_TIMINGS
	)
end
function s.spfilter(c,e,tp)
	return c:NotBanishedOrFaceup() and c:IsSetCard(0xd71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return ((chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GB)) or (chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_REMOVED))) and s.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	if Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GB,LOCATION_REMOVED,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetLabel(1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GB,LOCATION_REMOVED,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,g:GetFirst():GetControler(),g:GetFirst():GetLocation())
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetLabel(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()~=1 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToChain() and tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.filter1(c,tp,act)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.filter2,tp,0,LOCATION_MZONE,1,c,c:GetAttribute(),act)
		and (not act or c:IsAbleToChangeControler())
end
function s.filter2(c,attr,act)
	return c:IsFaceup() and c:IsAttribute(attr) and (not act or c:IsAbleToChangeControler())
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp,true) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_CONTROL)
	local g1=Duel.SelectMatchingCard(p,s.filter1,p,LOCATION_MZONE,0,1,1,nil,p,true)
	if #g1>0 then
		local attr=g1:GetFirst():GetAttribute()
		Duel.HintSelection(g1)
		Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_CONTROL)
		local g2=Duel.SelectMatchingCard(1-p,s.filter2,1-p,LOCATION_MZONE,0,1,1,nil,attr,true)
		if #g2>0 then
			Duel.HintSelection(g2)
			local c1=g1:GetFirst()
			local c2=g2:GetFirst()
			Duel.SwapControl(c1,c2,0,0)
		end
	end
end