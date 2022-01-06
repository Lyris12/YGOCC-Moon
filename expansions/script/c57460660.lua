--Shogun Scintillante Puntodifuoco
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--custom fusion summon (methods #1 and #2)
	local fun={(function(c,fc,sub,mg,sg) return cid.mfilter2(c,fc,sub,mg,sg) and not c:IsHasEffect(6205579) end),(function(c,fc,sub,mg,sg) return cid.mfilter1(c,fc,sub,mg,sg) and not c:IsHasEffect(6205579) end)}
	c:EnableReviveLimit()
	local fus=Effect.CreateEffect(c)
	fus:SetType(EFFECT_TYPE_SINGLE)
	fus:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	fus:SetCode(EFFECT_FUSION_MATERIAL)
	fus:SetCondition(cid.FusionConditionMix(true,false,cid.mfilter2,1,2,table.unpack(fun,2)))
	fus:SetOperation(cid.FusionOperationMix(true,false,cid.mfilter2,1,2,table.unpack(fun,2)))
	c:RegisterEffect(fus)
	--discard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cid.dccon)
	e1:SetTarget(cid.dctg)
	e1:SetOperation(cid.dcop)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(cid.rmcon)
	e2:SetOperation(cid.rmop)
	c:RegisterEffect(e2)
	--check disabled status
	if not cid.global_check then
		cid.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(cid.registerop)
		Duel.RegisterEffect(ge1,0)
	end
end
--fusion summon
function cid.FusionConditionMix(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,g,gc,chkfnf)
				if g==nil then return insf and aux.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=chkfnf>>8~=0
				local sub=sub or notfusion
				local mg=g:Filter(aux.FConditionFilterMix,c,c,sub,fun1,table.unpack(funs))
				local minc2=minc
				local maxc2=maxc
				if not mg:IsExists(cid.mfilterfus,1,nil) then minc2=minc+1 end
				if gc then
					if not mg:IsContains(gc) then return false end
					local sg=Group.CreateGroup()
					return aux.FSelectMixRep(gc,tp,mg,sg,c,sub,chkf,fun1,minc2,maxc,table.unpack(funs))
				end
				local sg=Group.CreateGroup()
				return mg:IsExists(aux.FSelectMixRep,1,nil,tp,mg,sg,c,sub,chkf,fun1,minc2,maxc,table.unpack(funs))
			end
end
function cid.FusionOperationMix(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=chkfnf>>8~=0
				local sub=sub or notfusion
				local mg=eg:Filter(aux.FConditionFilterMix,c,c,sub,fun1,table.unpack(funs))
				local sg=Group.CreateGroup()
				local minc2=minc
				local maxc2=maxc
				local fun12=fun1
				local opt=0
				if not mg:IsExists(cid.mfilterfus,1,nil) then 
					minc2=minc+1
				else
					if mg:IsExists(cid.mfilter2,3,nil) then
						opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,2))
					end
				end
				if gc then sg:AddCard(gc) end
				if opt==0 then fun12=cid.mfilterfus maxc2=maxc-1 end
				if opt==1 then minc2=minc+1 end
				while sg:GetCount()<maxc+#funs do
					local cg=mg:Filter(aux.FSelectMixRep,sg,tp,mg,sg,c,sub,chkf,fun12,minc2,maxc2,table.unpack(funs))
					if cg:GetCount()==0 then break end
					local finish=aux.FCheckMixRepGoal(tp,sg,c,sub,chkf,fun12,minc2,maxc2,table.unpack(funs))
					local cancel_group=sg:Clone()
					if gc then cancel_group:RemoveCard(gc) end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local tc=cg:SelectUnselect(cancel_group,tp,finish,false,minc2+#funs,maxc2+#funs)
					if not tc then break end
					if sg:IsContains(tc) then
						sg:RemoveCard(tc)
					else
						sg:AddCard(tc)
					end
				end
				Duel.SetFusionMaterial(sg)
			end
end
--check disabled status
function cid.registerop(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsDisabled),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,nil)
	local d=Duel.GetMatchingGroup(Card.IsDisabled,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,nil)
	if g:GetCount()>0 then
		for tc in aux.Next(g) do
			if tc:GetFlagEffect(id)<=0 then
				tc:RegisterFlagEffect(id,RESET_EVENT+EVENT_CUSTOM+1010101,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
			end
			if tc:GetFlagEffectLabel(id)~=100 then
				tc:SetFlagEffectLabel(id,100)
			end
		end
	end
	if d:GetCount()>0 then
		local reg=Group.CreateGroup()
		for tc2 in aux.Next(d) do
			if tc2:GetFlagEffect(id)<=0 then
				tc2:RegisterFlagEffect(id,RESET_EVENT+EVENT_CUSTOM+1010101,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
			end
			if tc2:GetFlagEffectLabel(id)~=200 then
				reg:AddCard(tc2)
				tc2:SetFlagEffectLabel(id,200)
			end
		end
		if reg:GetCount()>0 then
			Duel.RaiseEvent(reg,EVENT_CUSTOM+id,e,0,0,0,0)
		end
	end
end
--filters
function cid.mfilter1(c)
	return c:IsFusionSetCard(0xb05)
end
function cid.mfilter2(c)
	return c:IsFusionSetCard(0xb05)
end
function cid.mfilterfus(c)
	return c:IsFusionSetCard(0xb05) and c:IsFusionType(TYPE_FUSION)
end
function cid.checkrmcopy(c,g)
	return c:IsAbleToRemove() and g:IsExists(cid.rmcheck,1,nil,c:GetCode())
end
function cid.rmcheck(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
--discard
function cid.dccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function cid.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
function cid.dcop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND,nil)
	if g:GetCount()<=0 then return end
	local sg=g:Select(1-tp,1,1,nil)
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
--banish
function cid.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.checkrmcopy,tp,0,LOCATION_DECK,nil,eg)
	if g:GetCount()>0 then
		local rc=g:Select(1-tp,1,1,nil)
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	else
		if eg:FilterCount(Card.IsType,nil,TYPE_EXTRA)==eg:GetCount() then return end
		local cg=Duel.GetFieldGroup(1-tp,LOCATION_DECK,0)
		Duel.ConfirmCards(tp,cg)
	end
end
