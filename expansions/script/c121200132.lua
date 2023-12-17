--Winter Spirit Gnome
--  Idea: Alastar Rainford
--  Script: Shad3
--  Editors: Keddy, Glitchy

local s,id=GetID()
function s.initial_effect(c)
	--summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.a_tg)
	e1:SetOperation(s.a_op)
	c:RegisterEffect(e1)
	--sync
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetTarget(s.syntg)
	e2:SetOperation(s.synop)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(s.synlimit)
	c:RegisterEffect(e3)
end
function s.a_fil(c,e,tp)
	return c:IsSetCard(ARCHE_WINTER_SPIRIT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.a_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.a_fil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.a_fil),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local c=e:GetHandler()
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,3))
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE|PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.a_dcd)
			e1:SetOperation(s.a_dop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.a_dcd(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id,e:GetLabel()) then
		e:Reset()
		return false
	end
	return true
end
function s.a_dop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end

function s.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
function s.customsynfilter(c,tp,syncard,tuner,f)
	if not (c:IsFaceup() and c:HasCounter(COUNTER_ICE) and (f==nil or f(c,syncard))) then return false end
	local e1=Effect.CreateEffect(tuner)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
	e1:SetOwnerPlayer(tp)
	e1:SetValue(aux.TRUE)
	c:RegisterEffect(e1)
	local res=c:IsCanBeSynchroMaterial(syncard,tuner)
	e1:Reset()
	return res
end
function s.syncheck(c,g,mg,og,exg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=s.syngoal(g,tp,lv,syncard,minc,ct,og,exg)
		or (ct<maxc and mg:IsExists(s.syncheck,1,g,g,mg,og,exg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
function s.syngoal(g,tp,lv,syncard,minc,ct,og,exg)
	return ct>=minc
		and g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
		and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		and g:FilterCount(s.exglimit,nil,og,exg)<=1
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
function s.exglimit(c,og,exg)
	return exg:IsContains(c) and not og:IsContains(c)
end
function s.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	
	local g=Group.FromCards(c)
	local mg=Duel.GetSynchroMaterial(tp):Filter(s.synfilter,c,syncard,c,f)
	local og=mg:Clone()
	local exg=Duel.GetMatchingGroup(s.customsynfilter,tp,0,LOCATION_MZONE,c,tp,syncard,c,f)
	mg:Merge(exg)
	return mg:IsExists(s.syncheck,1,g,g,mg,og,exg,tp,lv,syncard,minc,maxc)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	local mg=Duel.GetSynchroMaterial(tp):Filter(s.synfilter,c,syncard,c,f)
	local og=mg:Clone()
	local exg=Duel.GetMatchingGroup(s.customsynfilter,tp,0,LOCATION_MZONE,c,tp,syncard,c,f)
	mg:Merge(exg)
	for i=1,maxc do
		local cg=mg:Filter(s.syncheck,g,g,mg,og,exg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if s.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	if g:IsExists(s.exglimit,1,nil,og,exg) then
		Duel.Hint(HINT_CARD,tp,id)
	end
	Duel.SetSynchroMaterial(g)
end

function s.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_WATER)
end