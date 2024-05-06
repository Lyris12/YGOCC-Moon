--Shared Effects
Converguard=Converguard or {}

function Converguard.Is(c,ignore_set)
	local code=c:GetCode()
	if not ((code>=28940360) and (code<28940380)) then return false end
	return ignore_set or (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD))
end

function Converguard.EnableConvergence(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28940360,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(function(e,c,og) local tp=e:GetHandlerPlayer()
		local matg=Duel.GetMatchingGroup(Converguard.ConvCostFilter,tp,LOCATION_EXTRA,0,nil)
		return Converguard.CanTimeLeap(e,e:GetHandler(),og)
		and Duel.IsExistingMatchingCard(Converguard.ConvergenceFilter,tp,LOCATION_EXTRA,0,1,e:GetHandler(),e,tp,matg)
	end)
	--e1:SetCondition(Converguard.ConvergenceCon(filter))
	e1:SetOperation(Converguard.ConvergenceOp(filter))
	e1:SetValue(SUMMON_TYPE_TIMELEAP)
	e1:SetLabel(c:GetOriginalCode())
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_EXTRA,0)
	e2:SetTarget(function(e,c) return c:IsType(TYPE_TIMELEAP) end)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end


function Converguard.CanTimeLeap(e,c,og)
	return c.timeleap_proc:GetCondition()(e,c,og)
end
function Converguard.ConvergenceCon(filter)
	return function(e,c,og)
		if not c then return true end
		local tp=e:GetHandlerPlayer()
		if not (c.timeleap_proc:GetCondition()(e,c,og) and (Duel.GetLocationCountFromEx(tp)>1)) then return false end
		local matg=Duel.GetMatchingGroup(Converguard.ConvCostFilter,tp,LOCATION_EXTRA,0,nil)
		local xg=Duel.GetMatchingGroup(Converguard.ConvergenceFilter,tp,LOCATION_EXTRA,0,e:GetHandler(),e,tp,matg)
		return math.min(#matg,#xg)>0
	end
end
function Converguard.ConvCostFilter(c)
	return Converguard.Is(c) and c:IsFaceup() and c:IsAbleToRemove()
end
function Converguard.GetTimeleapFilter(c)
	local res=c.timeleap_filter
	if not res then return false end
	if type(filter)=="table" then
		filter=filter[1]
		Debug.Message(filter[1])
	end
	return filter
end
function Converguard.ConvergenceCostFilter(c,e,tp,tc)
	--Debug.Message(tc.timeleap_filter(c,e,Group.FromCards(c)))
	--local filter=Converguard.GetTimeleapFilter(tc)
	local mg=Group.FromCards(c)
	return Converguard.Is(c) and c:IsFaceup() and c:IsCanBeTimeleapMaterial(tc)
		--and tc.timeleap_filter(c,e,mg)
		and aux.TimeleapMaterialFilter(c,tc.timeleap_filter,e,tp,Group.CreateGroup(),mg,Group.CreateGroup(),tc,1,tc.timeleap_condition)
end
function Converguard.ConvergenceFilter(c,e,tp,matg)
	return Converguard.Is(c) and c:IsType(TYPE_TIMELEAP)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false)
		and matg:IsExists(Converguard.ConvergenceCostFilter,1,c,e,tp,c)
end
function Converguard.ConvGFilter(g)
	return g:GetClassCount(Card.GetFuture)==g:GetCount()
end
function Converguard.ConvPreGCheck(c,g)
	return not g:IsExists(Card.IsFuture,1,nil,c:GetFuture())
end
function Converguard.ConvergenceOp(filter)
	return function(e,tp,eg,ep,ev,re,r,rp,c,sg,og) local c=e:GetHandler()
		e:SetLabelObject(Group.CreateGroup())
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCountFromEx(tp)
		--Debug.Message(ft)
		local matg=Duel.GetMatchingGroup(Converguard.ConvCostFilter,tp,LOCATION_EXTRA,0,nil)
		--Debug.Message(#matg)
		local xg=Duel.GetMatchingGroup(Converguard.ConvergenceFilter,tp,LOCATION_EXTRA,0,c,e,tp,matg)
		--Debug.Message(#xg)
		local max=math.min(ft,#matg,#xg,3)
		--Debug.Message("Max "..max)
		c.timeleap_proc:GetTarget()(e,tp,eg,ep,ev,re,r,rp,1,c)
		if e:GetLabelObject():GetCount()<1 then return false end
		local procs={}
		local mats={}
		local timeleaps={}
		local tableSize=1
		--table.insert(procs,c.timeleap_proc)
		table.insert(mats,e:GetLabelObject())
		table.insert(timeleaps,c)
		--c.timeleap_proc:GetOperation()(e,tp,eg,ep,ev,re,r,rp,c)
		sg:AddCard(c)
		local origin = e:GetOwner()
		local firstchk=true
		Duel.Hint(HINT_CARD,tp,e:GetLabel())
		while #xg>0 and #sg<=max and #matg>0 and (firstchk or Duel.SelectYesNo(tp,aux.Stringid(28940360,1))) do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=xg:FilterSelect(tp,Converguard.ConvPreGCheck,1,1,nil,sg):GetFirst()
			local rg=matg:FilterSelect(tp,Converguard.ConvergenceCostFilter,1,1,nil,e,tp,tc)
			if #rg>0 then
				--e:SetLabelObject(rg)
				--matg:Sub(rg)
				table.insert(mats,rg)
				--table.insert(procs,tc.timeleap_proc:GetOperation())
				table.insert(timeleaps,tc)
				--tc.timeleap_proc:GetOperation()(e,tp,eg,ep,ev,re,r,rp,tc)
				sg:AddCard(tc)
				tableSize=tableSize+1
			end
			matg=Duel.GetMatchingGroup(Converguard.ConvCostFilter,tp,LOCATION_EXTRA,0,nil)
			for i=1,tableSize do matg:RemoveCard(mats[i]) end
			xg=Duel.GetMatchingGroup(Converguard.ConvergenceFilter,tp,LOCATION_EXTRA,0,c,e,tp,matg)
			xg:Sub(sg)
			firstchk=false
		end
		for i=1,tableSize do
			e:SetLabelObject(mats[i])
			local tc=timeleaps[i]
			tc.timeleap_proc:GetOperation()(e,tp,eg,ep,ev,re,r,rp,tc)
			tc:CompleteProcedure()
			--procs[i]:GetOperation()(e,tp,eg,ep,ev,re,r,rp,tc)
		end

		--[[local tg=xg:SelectSubGroup(tp,Converguard.ConvGFilter,false,1,max)
		local tc=tg:GetFirst()
		while tc do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=matg:FilterSelect(tp,Converguard.ConvergenceCostFilter,1,1,tc,e,tp,tc)
			--local rg=Duel.SelectMatchingCard(tp,Converguard.ConvergenceCostFilter,tp,LOCATION_EXTRA,0,1,1,tc,e,tc)
			e:SetLabelObject(rg)
			--aux.TimeleapOperation(function() end)(e,tp,eg,ep,ev,re,r,rp,tc)
			tc.timeleap_proc:GetOperation()(e,tp,eg,ep,ev,re,r,rp,tc)
			sg:AddCard(tc)
			tc=tg:GetNext()
		end]]
	end
end

function Converguard.EnableTimeleap(c,ft)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,ft,Converguard.TimeleapCon(c:GetOriginalAttribute()),Converguard.TimeleapMat)
	c:EnableReviveLimit()
end
function Converguard.TimeleapConFilter(c,att)
	return Converguard.Is(c) or (c:IsFaceup() and c:IsAttribute(att))
end
function Converguard.TimeleapCon(att)
	return function(e)
		return Duel.IsExistingMatchingCard(Converguard.TimeleapConFilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,att)
	end
end
function Converguard.TimeleapMat(c,e,mg)
	return not c:IsType(TYPE_TOKEN)
end
function Converguard.EnableFloat(c,ct)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp~=tp end)
	e1:SetTarget(Converguard.FloatTarget(ct))
	e1:SetOperation(Converguard.FloatOperation(ct))
	c:RegisterEffect(e1)
	return e1
end
function Converguard.FloatFilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function Converguard.FloatTarget(ct)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and Converguard.FloatFilter(chkc,e,tp) end
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(Converguard.FloatFilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,Converguard.FloatFilter,tp,LOCATION_REMOVED,0,1,ct,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_REMOVED)
	end
end
function Converguard.FloatOperation(ct)
	return function(e,tp)
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#g then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function Converguard.EnableRecurrence(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return rp==1-tp and eg:IsExists(Converguard.RecurrenceFilter,1,nil,tp)
	end)
	e1:SetTarget(Converguard.RecurrenceTarget)
	e1:SetOperation(Converguard.RecurrenceOperation)
	c:RegisterEffect(e1)
	return e1
end
function Converguard.RecurrenceFilter(c,tp,rp)
	return Converguard.Is(c) and c:GetPreviousControler()==tp and not c:IsReason(REASON_DESTROY)
end
function Converguard.RecurrenceTarget(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,c:GetLocation())
end
function Converguard.RecurrenceOperation(e,tp) local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end



function Converguard.ConvProcFilter(c,e,tp,ct)
	return Converguard.ConvTarget(e,c,SUMMON_TYPE_TIMELEAP,tp,tp,false,false,POS_FACEUP,0xff,ct)
end
function Converguard.ConvTargetProc(e,tp,eg,ep,ev,re,r,rp,chk)
	Debug.Message("Proc Check")
	return eg:IsExists(Converguard.ConvProcFilter,1,nil,e,tp,#eg)
end
function Converguard.ConvTarget(e, c, sumtype, sumplayer, target_player, nocheck, nolimit, pos, zone, count)
	return e:GetHandlerPlayer()==sumplayer and sumtype==SUMMON_TYPE_TIMELEAP
		and Duel.GetLocationCount(target_player,LOCATION_MZONE)>count
		and Duel.IsExistingMatchingCard(Converguard.ConvCostFilter,sumplayer,LOCATION_EXTRA,0,1,nil)
		and not Duel.IsPlayerAffectedByEffect(sumplayer,EFFECT_IGNORE_TIMELEAP_HOPT)
end
function Converguard.ConvFilter(c,e,tp,sumtype, sumplayer, target_player, nocheck, nolimit, pos, zone, matg)
	return Converguard.Is(c) and c:IsType(TYPE_TIMELEAP)
		and c:IsCanBeSpecialSummoned(e,sumtype, sumplayer, nocheck, nolimit, pos, zone)
		--and Converguard.CanLeapUsing(c,matg,0)
end

function Converguard.CanLeapUsing(c,matg,chk)
	local res=false
	if c:IsHasEffect(EFFECT_SPSUMMON_PROC) then
		local tef={c:IsHasEffect(EFFECT_SPSUMMON_PROC)}
		for _,te in ipairs(tef) do
			if te:GetValue()==SUMMON_TYPE_TIMELEAP and not res then
				if chk==0 and con then
					local con=te:GetCondition()
					if not con then res=true
					else
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_CONTINUOUS)
						e1:SetCode(EFFECT_EXTRA_TIMELEAP_MATERIAL)
						e1:SetTargetRange(LOCATION_EXTRA,0)
						e1:SetLabelObject(matg)
						e1:SetTarget(function(e,c) return e:GetLabelObject():IsContains(c) end)
						--e1:SetTarget(Converguard.SingularityMatFilter)
						c:RegisterEffect(e1)
						if con(e,c,matg) then res=true end
						e1:Reset()
					end
				else 
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EFFECT_EXTRA_TIMELEAP_MATERIAL)
					e1:SetTargetRange(LOCATION_EXTRA,0)
					e1:SetLabelObject(matg)
					e1:SetTarget(function(e,c) return e:GetLabelObject():IsContains(c) end)
					c:RegisterEffect(e1)
					if te:GetTarget()(e,tp,eg,ep,ev,re,r,rp,1,c) then
						te:GetOperation()(e,tp,eg,ep,ev,re,r,rp,c)
						res=true
					end
					e1:Reset()
					if res then return true end
				end
			end
		end
	end
	return res
end

function Converguard.ConvMatFilter(c)
	return c:IsFaceup() and (Converguard.Is(c) or c:IsType(TYPE_NORMAL))
end
function Converguard.CanConvLeap(c,e,tp)
	if not (Converguard.Is(c) and c:IsFacedown()) then return false end
	local res=false
	if c:IsHasEffect(EFFECT_SPSUMMON_PROC) then
		local tef={c:IsHasEffect(EFFECT_SPSUMMON_PROC)}
		for _,te in ipairs(tef) do
			if te:GetValue()==SUMMON_TYPE_TIMELEAP and not res then
				local con=te:GetCondition()
				if con then
					local matg=Duel.GetMatchingGroup(Converguard.ConvMatFilter,tp,LOCATION_EXTRA,0,nil)
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EFFECT_EXTRA_TIMELEAP_MATERIAL)
					e1:SetTargetRange(LOCATION_EXTRA,0)
					e1:SetLabelObject(matg)
					e1:SetTarget(function(e,c) return e:GetLabelObject():IsContains(c) end)
					--e1:SetTarget(Converguard.SingularityMatFilter)
					c:RegisterEffect(e1)
					if con(e,c,matg) then res=true end
					e1:Reset()
				end
			end
		end
	end
	return res
end

