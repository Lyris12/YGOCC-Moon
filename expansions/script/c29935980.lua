--Il Giglio Celato di Soletluna, Phianelle
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,3)
	local d1=c:DriveEffect(0,0,CATEGORY_DISABLE,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD,EVENT_ENGAGE,
		nil,
		nil,
		s.target,
		s.operation
	)
	local d2=c:DriveEffect(-3,1,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	----search
	local f=aux.Filter(Card.IsSetCard,0x209)
	local e2=Effect.CreateEffect(c)
	e2:Desc(5)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(aux.ToGraveCost(s.thcfilter,LOCATION_SZONE,LOCATION_SZONE))
	e2:SetTarget(aux.SearchTarget(f))
	e2:SetOperation(aux.SearchOperation(f))
	c:RegisterEffect(e2)
	--shuffle
	local e3=Effect.CreateEffect(c)
	e3:Desc(5)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetCondition(aux.DueToHavingZeroEnergyCond)
	e3:SetTarget(s.drawtg)
	e3:SetOperation(s.drawop)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then
		local c=e:GetHandler()
		return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and c:IsCanUpdateEnergy(tp,5,REASON_EFFECT)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
end
function s.setfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if c:IsForbidden() then return false end
	if not c:IsSetCard(0x209) or not c:IsType(TYPE_PANDEMONIUM) then return false end
	return aux.PandSSetCon(c,tp,true)(nil,e,tp,eg,ep,ev,re,r,rp) 
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		local rct = Duel.GetTurnPlayer()==tp and 2 or 1
		local chk1,chk2,chk3,res=Duel.Negate(tc,e,{RESET_PHASE+PHASE_END+RESET_SELF_TURN,rct})
		if res then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:IsEngaged() and c:IsCanUpdateEnergy(tp,5,REASON_EFFECT) then
				c:UpdateEnergy(5,tp,REASON_EFFECT,true)
			end
		end
	end
end

function s.spfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsFaceup() or not c:IsOriginalType(TYPE_MONSTER) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local ec=c:GetEquipTarget()
	return ec and ec:IsControler(tp) and ec:IsFaceup() and ec:IsMonster(TYPE_PANDEMONIUM) and ec:IsSetCard(0x209)
		and aux.PandSSetCon(ec,tp)(nil,e,tp,eg,ep,ev,re,r,rp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local tc=Duel.GetFirstTarget()
	local ec=tc:GetEquipTarget()
	if tc and tc:IsRelateToChain() then
		local fid=e:GetFieldID()
		if ec then
			ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1,fid)
		end
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
			and ec and ec:HasFlagEffectLabel(id,fid) and (ec:IsControler(tp) or ec:IsAbleToChangeControler()) and ec:IsMonster(TYPE_PANDEMONIUM) and aux.PandSSetCon(ec,tp)(nil,e,tp,eg,ep,ev,re,r,rp) then
			aux.PandSSet(ec,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end

function s.actfilter(c,tp)
	if c:IsAbleToRemove() then
		return true
	else
		if not (not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsAbleToChangeControler()) then return false end
		return Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,c)
	end
	return false
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_PANDEMONIUM) and c:IsSetCard(0x209)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.actfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.actfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SelectTarget(tp,s.actfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		local b1=tc:IsAbleToRemove()
		local b2 = (not tc:IsForbidden() and tc:CheckUniqueOnField(tp) and tc:IsAbleToChangeControler()
			and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,tc))
			
		local opt=aux.Option(id,tp,3,b1,b2)
		if opt==0 then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		elseif opt==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,tc)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.EquipAndRegisterLimit(tp,tc,g:GetFirst())
			end
		end
	end
end

function s.thcfilter(c,_,tp)
	local ec=c:GetEquipTarget()
	return ec and ec:IsFaceup() and ec:IsMonster() and ec:IsControler(tp) and ec:IsSetCard(0x209)
end

function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x209) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,tp)>0 and Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end