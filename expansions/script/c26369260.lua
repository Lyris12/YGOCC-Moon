--Psychostizia Pattuglia
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--pandemonium
	aux.AddOrigPandemoniumType(c)
	--activate
	local p1=Effect.CreateEffect(c)
	p1:GLString(0)
	p1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCondition(s.actcon)
	p1:SetTarget(s.acttg)
	p1:SetOperation(s.actop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,true,TYPE_PANDEMONIUM+TYPE_EFFECT+TYPE_TUNER,false,false,1,false,true)
	--set
	local p2=Effect.CreateEffect(c)
	p2:GLString(1)
	p2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	p2:SetProperty(EFFECT_FLAG_DELAY)
	p2:SetCode(EVENT_CUSTOM+id)
	p2:SetRange(LOCATION_SZONE)
	p2:SetCondition(s.sccon)
	p2:SetCost(s.sccost)
	p2:SetTarget(s.sctg)
	p2:SetOperation(s.scop)
	c:RegisterEffect(p2)
	--spsummon rule
	local e2=Effect.CreateEffect(c)
	e2:GLString(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x2c2)
		and c:GetPreviousCodeOnField()~=id and c:GetPreviousTypeOnField()&(TYPE_BIGBANG+TYPE_LINK)==0
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(s.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(s.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(eg,EVENT_CUSTOM+id,re,r,rp,ep,e:GetLabel())
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) and aux.PandActCheck(e) and s.acttg(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2c2,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM+TYPE_TUNER,1200,1750,3,RACE_PSYCHO,ATTRIBUTE_LIGHT)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
	or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2c2,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM+TYPE_TUNER,1200,1750,3,RACE_PSYCHO,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_PANDEMONIUM+TYPE_TUNER)
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end

function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return aux.PandActCheck(e) and (ev==tp or ev==PLAYER_ALL)
end
function s.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return e:GetHandler():IsDestructable(e,REASON_COST,tp) end
	Duel.Destroy(e:GetHandler(),REASON_COST)
end
function s.setfilter(c,e,tp,eg,ep,ev,re,r,rp,lab)
	if c:IsForbidden() then return false end
	if c:IsLocation(LOCATION_DECK+LOCATION_HAND) or c:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED) and c:IsFacedown() then return false end
	if c:IsType(TYPE_FIELD) then
		return false
	elseif c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsSSetable(false) and (lab==1 or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
	elseif c:IsType(TYPE_PANDEMONIUM) then
		return aux.PandSSetCon(c,tp,true)(nil,e,tp,eg,ep,ev,re,r,rp) and (lab==1 or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
	end
	return false
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=eg:IsExists(s.setfilter,1,nil,e,tp,eg,ep,ev,re,r,rp,e:GetLabel())
		e:SetLabel(0)
		return res
	end
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=eg:Filter(aux.NecroValleyFilter(s.setfilter),nil,e,tp,eg,ep,ev,re,r,rp,0)
	if #g<=0 then return end
	local tc=(#g==1) and g:GetFirst() or g:Select(tp,1,1,nil):GetFirst()
	if tc then
		if tc:IsType(TYPE_PANDEMONIUM) then
			aux.PandSSet(tc,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		else
			Duel.SSet(tp,tc)
		end
		if tc:IsLocation(LOCATION_SZONE) and tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,Group.FromCards(tc))
			if tc:IsType(TYPE_QUICKPLAY) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
			if tc:IsType(TYPE_TRAP) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end

function s.tgfilter(c,e,tp,ec)
	local mg=Group.FromCards(ec,c)
	local invalid_lv=(c:GetLevel()==e:GetHandler():GetLevel()) and c:GetLevel()
	return c:IsFaceup() and c:IsSetCard(0x2c2) and c:GetLevel()>0 and Duel.IsExistingMatchingCard(s.bbfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,invalid_lv)
end
function s.bbfilter(c,e,tp,mg,invalid_lv)
	if not c:IsType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_BIGBANG) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	for lv=3,5 do
		if not invalid_lv or lv~=invalid_lv then
			local restore_lv={}
			for mat in aux.Next(mg) do
				table.insert(restore_lv,mat:GetLevel())
				mat:AssumeProperty(ASSUME_LEVEL,lv)
			end
			if c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil,mg) then
				local ct=1
				for mat in aux.Next(mg) do
					mat:AssumeProperty(ASSUME_LEVEL,restore_lv[ct])
					ct=ct+1
				end
				return true
			elseif c:IsType(TYPE_XYZ) and c:IsXyzSummonable(mg,2,2) then
				local ct=1
				for mat in aux.Next(mg) do
					mat:AssumeProperty(ASSUME_LEVEL,restore_lv[ct])
					ct=ct+1
				end
				return true
			elseif c:IsType(TYPE_LINK) and c:IsLinkSummonable(mg,nil,2,2) then
				local ct=1
				for mat in aux.Next(mg) do
					mat:AssumeProperty(ASSUME_LEVEL,restore_lv[ct])
					ct=ct+1
				end
				return true
			elseif c:IsType(TYPE_BIGBANG) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) then
				local et=global_card_effect_table[c]
				for _,e in ipairs(et) do
					if e:GetCode()==EFFECT_SPSUMMON_PROC then
						local ev=e:GetValue()
						local ec=e:GetCondition()
						if ev and (aux.GetValueType(ev)=="function" and ev(ef,c)&340==340 or ev&340==340) and (not ec or ec(e,c,mg)) then
							local ct=1
							for mat in aux.Next(mg) do
								mat:AssumeProperty(ASSUME_LEVEL,restore_lv[ct])
								ct=ct+1
							end
							return true
						end
					end
				end
			end
			local ct=1
			for mat in aux.Next(mg) do
				mat:AssumeProperty(ASSUME_LEVEL,restore_lv[ct])
				ct=ct+1
			end
		end
	end
	return false
end
function s.exact_bbfilter(c,e,tp,mg)
	if not c:IsType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_BIGBANG) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	if c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil,mg) then
		return true
	elseif c:IsType(TYPE_XYZ) and c:IsXyzSummonable(mg,2,2) then
		return true
	elseif c:IsType(TYPE_LINK) and c:IsLinkSummonable(mg,nil,2,2) then
		return true
	elseif c:IsType(TYPE_BIGBANG) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) then
		local et=global_card_effect_table[c]
		for _,e in ipairs(et) do
			if e:GetCode()==EFFECT_SPSUMMON_PROC then
				local ev=e:GetValue()
				local ec=e:GetCondition()
				if ev and (aux.GetValueType(ev)=="function" and ev(ef,c)&340==340 or ev&340==340) and (not ec or ec(e,c,mg)) then
					return true
				end
			end
		end
	end
	return false
end
function s.simple_bbfilter(c,e,tp,mg)
	return c:IsType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_BIGBANG) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then return e:GetHandler():GetLevel()>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e,tp,e:GetHandler())
	local invalid_levels={}
	local invalid_lv=(c:GetLevel()==g:GetFirst():GetLevel()) and c:GetLevel()
	if invalid_lv then
		table.insert(invalid_levels,invalid_lv)
	end
	local mg=Group.FromCards(c,g:GetFirst())
	local ed=Duel.GetMatchingGroup(s.simple_bbfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	for lv=3,5 do
		if not invalid_lv or lv~=invalid_lv then
			local matchfound=false
			for mat in aux.Next(mg) do
				mat:AssumeProperty(ASSUME_LEVEL,lv)
			end
			for ec in aux.Next(ed) do
				if ec:IsType(TYPE_SYNCHRO) and ec:IsSynchroSummonable(nil,mg) then
					matchfound=true
					break
				elseif ec:IsType(TYPE_XYZ) and ec:IsXyzSummonable(mg,2,2) then
					matchfound=true
					break
				elseif ec:IsType(TYPE_LINK) and ec:IsLinkSummonable(mg,nil,2,2) then
					matchfound=true
					break
				elseif ec:IsType(TYPE_BIGBANG) and ec:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) then
					local et=global_card_effect_table[ec]
					for _,e in ipairs(et) do
						if e:GetCode()==EFFECT_SPSUMMON_PROC then
							local ev=e:GetValue()
							local eco=e:GetCondition()
							if ev and (aux.GetValueType(ev)=="function" and ev(ef,ec)&340==340 or ev&340==340) and (not eco or eco(e,c,mg)) then
								matchfound=true
								break
							end
						end
					end
				end
			end
			if not matchfound then
				table.insert(invalid_levels,lv)
			end
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,3,5,table.unpack(invalid_levels))
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local mg=Group.FromCards(c,tc)
	local mc=mg:GetFirst()
	while mc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		mc:RegisterEffect(e1)
		mc=mg:GetNext()
	end
	if c:IsImmuneToEffect(e) or tc:IsImmuneToEffect(e) then return end
	Duel.RaiseEvent(mg,EVENT_ADJUST,nil,0,PLAYER_NONE,PLAYER_NONE,0)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(s.exact_bbfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg):Select(tp,1,1,nil)
	local sc=g:GetFirst()
	if not sc then return end
	if sc:IsType(TYPE_SYNCHRO) then
		Duel.SynchroSummon(tp,sc,nil,mg)
	elseif sc:IsType(TYPE_XYZ) then
		Duel.XyzSummon(tp,sc,mg)
	elseif sc:IsType(TYPE_LINK) then
		Duel.LinkSummon(tp,sc,mg,nil,2,2)
	elseif sc:IsType(TYPE_BIGBANG) then
		local eid=e:GetFieldID()
		for tc in aux.Next(mg) do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1,eid)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetTargetRange(0xff,0xff)
		e1:SetTarget(s.limitmat)
		e1:SetLabel(eid)
		e1:SetValue(1)
		bigbang_limit_mats_operation = e1
		Duel.SpecialSummonRule(tp,sc)
		if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
	end
end
function s.limitmat(e,c)
	return c:GetFlagEffect(id)<=0 or c:GetFlagEffectLabel(id)~=e:GetLabel()
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp,true) end
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsRelateToEffect(e)
	and e:GetHandler():IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp,true) then
		aux.PandAct(e:GetHandler())(e,tp,eg,ep,ev,re,r,rp)
		local te=e:GetHandler():GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=e:GetHandler():GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
	end
end