--Common Gardrenial Effects

Gardrenial=Gardrenial or {}

Gardrenial.Code = 0x248
Gardrenial.InsectID = 28940000
Gardrenial.PlantID = 28940003
function Gardrenial.Is(c) return c:IsSetCard(0x248) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD)) end
function Gardrenial.FlipRace(rc)
	if rc==RACE_PLANT then return RACE_INSECT end
	if rc==RACE_INSECT then return RACE_PLANT end
	return rc
end
function Gardrenial.EnableTrackers(c)
	if global_gardrenial_check then return end
	global_gardrenial_check = true
	Duel.AddCustomActivityCounter(Gardrenial.InsectID,ACTIVITY_SUMMON,function(c) return not c:IsRace(RACE_INSECT) end)
	Duel.AddCustomActivityCounter(Gardrenial.PlantID,ACTIVITY_SUMMON,function(c) return not c:IsRace(RACE_PLANT) end)
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(Gardrenial.FusionCon)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.RegisterFlagEffect(rp,28940002,RESET_PHASE+PHASE_END,1,1,1) end)
	Duel.RegisterEffect(e1,0)
	Duel.RegisterEffect(e1,1)
end
function Gardrenial.NSInsect(p)
	return Duel.GetCustomActivityCount(Gardrenial.InsectID,p,ACTIVITY_SUMMON)~=0
		or Duel.GetFlagEffect(p,Gardrenial.InsectID)~=0
end
function Gardrenial.NSPlant(p)
	return Duel.GetCustomActivityCount(Gardrenial.PlantID,p,ACTIVITY_SUMMON)~=0
		or Duel.GetFlagEffect(p,Gardrenial.PlantID)~=0
end
function Gardrenial.FusionCon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_FUSION)==REASON_FUSION and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_MZONE)
end
function Gardrenial.DidFusion(tp) return Duel.GetFlagEffect(tp,28940002)~=0 end
function Gardrenial.EnableNS(p,race)
	local code
	if race==RACE_INSECT then code=Gardrenial.InsectID end
	if race==RACE_PLANT then code=Gardrenial.PlantID end
	Duel.RegisterFlagEffect(p,code,RESET_PHASE+PHASE_END,0,1,1)
end

function Gardrenial.CreateDualityEffect(c,rc)
	local e1=Effect.CreateEffect(c)
	e1:SetCondition(Gardrenial.CheckOther(rc))
	e1:SetCost(Gardrenial.BanishSame(rc))
	return e1
end
function Gardrenial.CheckOther(rc)
	return function(e,tp,e,eg,ep,ev,re,r,rp)
		return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,Gardrenial.FlipRace(rc))
	end
end
function Gardrenial.BanishSameFilter(c,rc) return c:IsRace(rc) and c:IsAbleToRemoveAsCost() end
function Gardrenial.BanishSame(rc)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(Gardrenial.BanishSameFilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),rc) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Gardrenial.BanishSameFilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),rc)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end

gardrenial_mats=Group.CreateGroup()

--Fusion Overwrite
auxiliary_f_operation_mix_rep=Auxiliary.FOperationMixRep
Auxiliary.FOperationMixRep=function(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=chkfnf&0x100>0
				local concat_fusion=chkfnf&0x200>0
				local sub=(sub or notfusion) and not concat_fusion
				local mg=eg:Filter(Auxiliary.FConditionFilterMix,c,c,sub,concat_fusion,fun1,table.unpack(funs))
				local sg=Group.CreateGroup()
				if gc then sg:AddCard(gc) end
				while sg:GetCount()<maxc+#funs do
					local cg=mg:Filter(Auxiliary.FSelectMixRep,sg,tp,mg,sg,c,sub,chkfnf,fun1,minc,maxc,table.unpack(funs))
					if cg:GetCount()==0 then break end
					local finish=Auxiliary.FCheckMixRepGoal(tp,sg,c,sub,chkfnf,fun1,minc,maxc,table.unpack(funs))
					local cancel_group=sg:Clone()
					if gc then cancel_group:RemoveCard(gc) end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local tc=cg:SelectUnselect(cancel_group,tp,finish,false,minc+#funs,maxc+#funs)
					if not tc then break end
					if sg:IsContains(tc) then
						sg:RemoveCard(tc)
						gardrenial_mats:RemoveCard(c)
					else
						sg:AddCard(tc)
						gardrenial_mats:AddCard(c)
					end
				end
				Duel.SetFusionMaterial(sg)
				gardrenial_mats:Clear()
			end
end
