--Il Rovo Selvatico di Soletluna, Vesper
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,3)
	local d1=c:DriveEffect(0,0,CATEGORIES_SEARCH,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O,EFFECT_FLAG_DDD,EVENT_ENGAGE,
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
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	----search
	local e2=Effect.CreateEffect(c)
	e2:Desc(4)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(aux.DriveSummonedCond)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
	--shuffle
	local e3=Effect.CreateEffect(c)
	e3:Desc(5)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetCondition(aux.DueToHavingZeroEnergyCond)
	e3:SetTarget(s.drawtg)
	e3:SetOperation(s.drawop)
	c:RegisterEffect(e3)
end
function s.setfilter(c)
	return c:IsMonster(TYPE_PANDEMONIUM) and c:IsSetCard(0x209)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.PandSSetFilter(s.setfilter,tp),tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end
function s.fdfilter(c,tp)
	return c:IsCode(id+1) and (c:IsAbleToHand() or c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp,true,true))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.HintMessage(tp,HINTMSG_SSET)
	local g=Duel.SelectMatchingCard(tp,aux.PandSSetFilter(s.setfilter,tp),tp,LOCATION_HAND,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	if #g>0 then
		local tc=g:GetFirst()
		if aux.PandSSet(tc,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)>0 and aux.PLChk(tc,tp,LOCATION_SZONE) and tc:IsFacedown()
			and Duel.IsExistingMatchingCard(s.fdfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
			Duel.HintMessage(tp,HINTMSG_OPERATECARD)
			local g=Duel.SelectMatchingCard(tp,s.fdfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
			Duel.ResetFlagEffect(tp,15248873)
			local tc=g:GetFirst()
			if tc then
				local b1=tc:IsAbleToHand()
				local te=tc:GetActivateEffect()
				if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
				local b2=te:IsActivatable(tp,true,true)
				Duel.ResetFlagEffect(tp,15248873)
				if b1 and (not b2 or Duel.SelectOption(tp,1190,1150)==0) then
					Duel.Search(tc,tp)
				else
					local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc then
						Duel.SendtoGrave(fc,REASON_RULE)
						Duel.BreakEffect()
					end
					Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
					te:UseCountLimit(tp,1,true)
					local tep=tc:GetControler()
					local cost=te:GetCost()
					if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
					Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
				end
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

function s.sfilter(c)
	return c:IsSpell(TYPE_QUICKPLAY) and c:IsSetCard(0x209) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end

function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x209)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	local ct=Duel.GetMatchingGroupCount(s.actfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) and ct>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_MZONE)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
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
function s.filter(c,tp)
	return c:IsFaceup() and c:IsMonster(TYPE_PANDEMONIUM) and c:IsSetCard(0x209) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,tp)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
		if #g>0 then
			aux.PandAct(g:GetFirst())(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end