--La Sanguigna Lycoris di Soletluna, Sistina
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,3)
	local d1=c:DriveEffect(0,0,CATEGORY_DESTROY,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD,EVENT_ENGAGE,
		nil,
		nil,
		s.target,
		s.operation
	)
	local d2=c:DriveEffect(-3,2,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(aux.DriveSummonedCond)
	e2:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e2)
	--shuffle
	local e3=Effect.CreateEffect(c)
	e3:Desc(4)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetCondition(aux.DueToHavingZeroEnergyCond)
	e3:SetTarget(s.drawtg)
	e3:SetOperation(s.drawop)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.setfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if c:IsForbidden() then return false end
	if not c:IsSetCard(0x209) or not c:IsType(TYPE_PANDEMONIUM) then return false end
	return aux.PandSSetCon(c,tp,true)(nil,e,tp,eg,ep,ev,re,r,rp) 
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
		local tc=g:GetFirst()
		if tc then
			aux.PandSSet(tc,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end

function s.spfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsFaceup() or not c:IsOriginalType(TYPE_MONSTER) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or not (c:IsControler(tp) or (c:CheckUniqueOnField(tp) and c:IsAbleToChangeControler())) then
		return false
	end
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

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct<0 then ct=0 end
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end

function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,tp)>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end