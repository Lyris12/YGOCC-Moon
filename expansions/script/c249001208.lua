--Uru-Chain Synchron
function c249001208.initial_effect(c)
	if Auxiliary.AddSynchroProcedure then
		if not c249001208_AddSynchroProcedure then
			c249001208_AddSynchroProcedure=Auxiliary.AddSynchroProcedure
			Auxiliary.AddSynchroProcedure = function (c,f1,f2,minc,maxc)
				local code=c:GetOriginalCode()
				local mt=_G["c" .. code]
				mt.f1=f1
				mt.f2=f2
				mt.minc=minc
				if maxc==nil then mt.maxc=99 else mt.maxc=maxc end
				mt.ismix=false
				c249001208_AddSynchroProcedure(c,f1,f2,minc,maxc)
			end
		end
	end
	if Auxiliary.AddSynchroMixProcedure then
		if not c249001208_AddSynchroMixProcedure then
			c249001208_AddSynchroMixProcedure=Auxiliary.AddSynchroMixProcedure
			Auxiliary.AddSynchroMixProcedure = function(c,f1,f2,f3,f4,minc,maxc,gc)
				local code=c:GetOriginalCode()
				local mt=_G["c" .. code]
				mt.f1=f1
				mt.f2=f2
				mt.f3=f3
				mt.f4=f4
				mt.minc=minc
				if maxc==nil then mt.maxc=99 else mt.maxc=maxc end
				mt.gc=gc
				mt.ismix=true
				c249001208_AddSynchroMixProcedure(c,f1,f2,f3,f4,minc,maxc,gc)
			end
		end
	end
	aux.EnablePendulumAttribute(c)
	--enable chain tuning
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,2490012081)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249001208.cost)
	e1:SetOperation(c249001208.operation)
	c:RegisterEffect(e1)
	--Banish
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetCondition(c249001208.rmcon)
	c:RegisterEffect(e2)
	--draw (pzone)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,2490012082)
	e3:SetCondition(c249001208.condition)
	e3:SetCost(c249001208.cost)
	e3:SetTarget(c249001208.target)
	e3:SetOperation(c249001208.operation)
	c:RegisterEffect(e3)
end
function c249001208.costfilter(c)
	return c:IsSetCard(0x232) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c249001208.costfilter2(c,e)
	return c:IsSetCard(0x232) and not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
function c249001208.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249001208.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
	or Duel.IsExistingMatchingCard(c249001208.costfilter2,tp,LOCATION_HAND,0,1,nil)) end
	local option
	if Duel.IsExistingMatchingCard(c249001208.costfilter2,tp,LOCATION_HAND,0,1,nil)  then option=0 end
	if Duel.IsExistingMatchingCard(c249001208.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249001208.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
	and Duel.IsExistingMatchingCard(c249001208.costfilter2,tp,LOCATION_HAND,0,1,nil) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249001208.costfilter2,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249001208.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249001208.edfilter(c,tp)
	local code=c:GetOriginalCode()
	local mt=_G["c" .. code]
	return c:IsControler(tp) and c:IsType(TYPE_SYNCHRO) and mt.minc
end
function c249001208.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c249001208.edfilter,tp,0xFF,0xFF,nil,tp)
	local tc=g:GetFirst()
	while tc do
		local code=tc:GetOriginalCode()
		local mt=_G["c" .. code]
		if mt.ismix then
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(503)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetRange(LOCATION_EXTRA)
			e1:SetCondition(c249001208.SynMixCondition(mt.f1,mt.f2,mt.f3,mt.f4,mt.minc,mt.maxc,mt.gc))
			e1:SetTarget(c249001208.SynMixTarget(mt.f1,mt.f2,mt.f3,mt.f4,mt.minc,mt.maxc,mt.gc))
			e1:SetOperation(c249001208.SynMixOperation(mt.f1,mt.f2,mt.f3,mt.f4,mt.minc,mt.maxc,mt.gc))
			e1:SetValue(SUMMON_TYPE_SYNCHRO)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		else
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(503)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetRange(LOCATION_EXTRA)
			e1:SetCondition(c249001208.SynCondition(mt.f1,mt.f2,mt.minc,mt.maxc))
			e1:SetTarget(c249001208.SynTarget(mt.f1,mt.f2,mt.minc,mt.maxc))
			e1:SetOperation(c249001208.SynOperation(mt.f1,mt.f2,mt.minc,mt.maxc))
			e1:SetValue(SUMMON_TYPE_SYNCHRO)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end			
		tc=g:GetNext()	
	end
end
function c249001208.SynCondition(f1,f2,minc,maxc)
	return	function(e,c,smat,mg,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE+LOCATION_MZONE,0,c,TYPE_MONSTER)
				local canremove=true
				if smat and not smat:IsAbleToRemoveAsCost() then canremove=false end
					local smat2=mg:GetFirst()
					while smat2 do
						if smat2 and not smat2:IsAbleToRemoveAsCost() then canremove=false end	
						smat2=mg:GetNext()
					end
				if not canremove then return false end
				if smat and smat:IsType(TYPE_TUNER) and (not f1 or f1(smat)) then
					return Duel.CheckTunerMaterial(c,smat,f1,f2,minc,maxc,mg) end
				return Duel.CheckSynchroMaterial(c,f1,f2,minc,maxc,smat,mg)
			end
end
function c249001208.SynTarget(f1,f2,minc,maxc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE+LOCATION_MZONE,0,c,TYPE_MONSTER)
				local canremove=true
				if smat and not smat:IsAbleToRemoveAsCost() then canremove=false end
					local smat2=mg:GetFirst()
					while smat2 do
						if smat2 and not smat2:IsAbleToRemoveAsCost() then canremove=false end	
						smat2=mg:GetNext()
					end
				if not canremove then return false end
				local g=nil
				if smat and smat:IsType(TYPE_TUNER) and (not f1 or f1(smat)) then
					g=Duel.SelectTunerMaterial(c:GetControler(),c,smat,f1,f2,minc,maxc,mg)
				else
					g=Duel.SelectSynchroMaterial(c:GetControler(),c,f1,f2,minc,maxc,smat,mg)
				end
				if g then
					g:KeepAlive()
					e:SetLabelObject(g)
					return true
				else return false end
			end
end
function c249001208.SynOperation(f1,f2,minct,maxc)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
					Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_SYNCHRO)
				else
					Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
				end
				g:DeleteGroup()
			end
end
function c249001208.SynMaterialFilter(c,syncard)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsCanBeSynchroMaterial(syncard)
end
function c249001208.GetSynMaterials(tp,syncard)
	local mg=Duel.GetMatchingGroup(c249001208.SynMaterialFilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,nil,syncard)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		local mg2=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND,0,nil,syncard)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	return mg
end
function c249001208.SynMixCondition(f1,f2,f3,f4,minc,maxc,gc)
	return	function(e,c,smat,mg1,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local tp=c:GetControler()
				local mg
				local mgchk=false
				if mg1 then
					mg=mg1
					mgchk=true
				else
					mg=c249001208.GetSynMaterials(tp,c)
				end
				if smat~=nil then mg:AddCard(smat) end
				return mg:IsExists(Auxiliary.SynMixFilter1,1,nil,f1,f2,f3,f4,minc,maxc,c,mg,smat,gc,mgchk)
			end
end
function c249001208.SynMixTarget(f1,f2,f3,f4,minc,maxc,gc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg1,min,max)
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local g=Group.CreateGroup()
				local mg
				if mg1 then
					mg=mg1
				else
					mg=c249001208.GetSynMaterials(tp,c)
				end
				if smat~=nil then mg:AddCard(smat) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
				local c1=mg:FilterSelect(tp,Auxiliary.SynMixFilter1,1,1,nil,f1,f2,f3,f4,minc,maxc,c,mg,smat,gc):GetFirst()
				g:AddCard(c1)
				if f2 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
					local c2=mg:FilterSelect(tp,Auxiliary.SynMixFilter2,1,1,c1,f2,f3,f4,minc,maxc,c,mg,smat,c1,gc):GetFirst()
					g:AddCard(c2)
					if f3 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
						local c3=mg:FilterSelect(tp,Auxiliary.SynMixFilter3,1,1,Group.FromCards(c1,c2),f3,f4,minc,maxc,c,mg,smat,c1,c2,gc):GetFirst()
						g:AddCard(c3)
					end
				end
				local g4=Group.CreateGroup()
				for i=0,maxc-1 do
					local mg2=mg:Clone()
					if f4 then
						mg2=mg2:Filter(f4,g,c)
					else
						mg2:Sub(g)
					end
					local cg=mg2:Filter(Auxiliary.SynMixCheckRecursive,g4,tp,g4,mg2,i,minc,maxc,c,g,smat,gc)
					if cg:GetCount()==0 then break end
					local minct=1
					if Auxiliary.SynMixCheckGoal(tp,g4,minc,i,c,g,smat,gc) then
						minct=0
					end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
					local tg=cg:Select(tp,minct,1,nil)
					if tg:GetCount()==0 then break end
					g4:Merge(tg)
				end
				g:Merge(g4)
				if g:GetCount()>0 then
					g:KeepAlive()
					e:SetLabelObject(g)
					return true
				else return false end
			end
end
function c249001208.SynMixOperation(f1,f2,f3,f4,minct,maxc,gc)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
					Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_SYNCHRO)
				else
					Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
				end
				g:DeleteGroup()
			end
end
function c249001208.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsReason(REASON_MATERIAL) and c:IsReason(REASON_SYNCHRO)
end
function c249001208.tunerfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
function c249001208.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x232)
end
function c249001208.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c249001208.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001208.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Draw(tp,1,REASON_EFFECT)
end