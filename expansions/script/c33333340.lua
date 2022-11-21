--Decimosigillo Liberato
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	c:Activate(0,CATEGORY_SPECIAL_SUMMON,nil,nil,{true,false,true},
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsSetCard,0x7ec),LOCATION_MZONE,0,1),
		aux.LabelCost,
		s.target,
		s.activate
	)
	--set
	c:SentToGYTrigger(false,1,nil,true,nil,
		s.setcon,
		nil,
		s.settg,
		s.setop
	)
end
function s.rfilter(c,e,tp)
	return c:IsSetCard(0x7eb) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsReleasable() and c:HasLevel()
		and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel(),c:GetRace())
end
function s.spfilter(c,e,tp,lv,rc)
	return c:IsSetCard(0x7eb) and c:HasLevel() and not c:IsLevel(lv) and c:IsRace(rc)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local lab=e:GetLabel()
		if lab~=1 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,s.rfilter,1,nil,e,tp)
	end
	e:SetLabel(0)
	local g=Duel.SelectReleaseGroup(tp,s.rfilter,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local l1=e:GetLabel()
		e:SetLabel(l1,tc:GetLevel(),tc:GetRace())
		Duel.Release(g,REASON_COST)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local _,lv,rc=e:GetLabel()
	if not lv or not rc or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then Debug.Message('a') return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv,rc)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated()
		and re:GetHandler():IsSetCard(0x7eb,0x7ec)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,c:GetControler(),0)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end