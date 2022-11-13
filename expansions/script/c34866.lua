--Preservazione Iperdrive
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,34860)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.dfilter(c,e,tp)
	if not c:IsPreviousControler(tp) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if c:IsPreviousLocation(LOCATION_ONFIELD) then
		return c:IsType(TYPE_DRIVE) or (c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_DRIVE==TYPE_DRIVE)
	else
		return c:IsType(TYPE_DRIVE)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.dfilter,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local g=eg:Filter(s.dfilter,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if #g>1 then
		Duel.HintMessage(tp,HINTMSG_SPSUMMON)
		g=g:Select(tp,1,1,nil)
	end
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsFaceup() and (tc:GetAttack()>0 or tc:GetDefense()>0)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,34860),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local val=math.max(tc:GetAttack(),tc:GetDefense())
		if val<=0 then return end
		Duel.Recover(tp,val,REASON_EFFECT)
	end
end