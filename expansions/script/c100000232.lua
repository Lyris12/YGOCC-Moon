--[[
Mirrorshard Wing Speculomiric Dragon
Drago Speculomirico Ala Specchioframmentata
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 monsters with 2 or more of the same Type, Attribute and/or ATK
	aux.AddFusionProcFunRep(c,s.ffilter,2,false)
	--summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Once per turn (Quick Effect): You can target 1 face-up monster your opponent controls; until the end of this turn, this card's Type, Attribute and ATK becomes the same as that target's, and replace this effect with that monster's original effect, then, if this card was Fusion Summoned using 2 monsters with the same Type, Attribute and ATK, you can negate that target's effects until the end of this turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetLabelObject(e2)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
end
function s.fcheck(c,attr,race,atk)
	local ct=0
	if c:GetFusionAttribute()&attr>0 then
		ct=ct+1
	end
	if c:IsRace(race) then
		ct=ct+1
		if ct==2 then
			return true
		end
	end
	if c:IsAttack(atk) then
		ct=ct+1
		if ct==2 then
			return true
		end
	end
	return false
end
function s.locchk(c,p)
	return c:IsLocation(LOCATION_HAND|LOCATION_ONFIELD) and c:IsControler(p)
end
function s.ffilter(c,fc,sub,mg,sg)
	if not mg then return true end
	return #mg==2 and mg:IsExists(s.fcheck,1,c,c:GetFusionAttribute(),c:GetRace(),c:GetAttack()) and mg:IsExists(s.locchk,1,nil,fc:GetControler())
end

--E0
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end

--E2
function s.filter(c1,attr,race,atk,code)
	if not c1:IsFaceup() then return false end
	return c1:GetRace()~=race or c1:GetAttribute()~=attr or c1:GetAttack()~=atk or (c1:IsType(TYPE_EFFECT) and c1:GetOriginalCode()~=code)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local attr,race,atk,code=c:GetAttribute(),c:GetRace(),c:GetAttack(),c:GetOriginalCode()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,attr,race,atk,code) end
	if chk==0 then
		return c:IsLocation(LOCATION_MZONE) and Duel.IsExists(true,s.filter,tp,0,LOCATION_MZONE,1,nil,attr,race,atk,code)
	end
	local tc=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,attr,race,atk,code):GetFirst()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0,{tc:GetAttack()})
	if c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterialCount()>1 and e:GetLabel()==1 then
		Duel.SetTargetParam(1)
		e:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DISABLE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
	else
		Duel.SetTargetParam(0)
		e:SetCategory(CATEGORY_ATKCHANGE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToChain() or not c:IsFaceup() or not tc:IsRelateToChain() or not tc:IsFaceup() or not tc:IsControler(1-tp) then return end
	local check=false
	local attr,race,atk,code=tc:GetAttribute(),tc:GetRace(),tc:GetAttack(),tc:GetOriginalCode()
	if attr~=c:GetAttribute() then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(attr)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		if c:RegisterEffect(e3) and not check and not c:IsImmuneToEffect(e3) then
			check=true
		end
	end
	if race~=c:GetRace() then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(race)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		if c:RegisterEffect(e4) and not check and not c:IsImmuneToEffect(e4) then
			check=true
		end
	end
	local e5,_,_,diff=c:ChangeATK(atk,RESET_PHASE|PHASE_END,c)
	if not check and not c:IsImmuneToEffect(e5) and diff~=0 then
		check=true
	end
	local res=c:CopyEffect(code,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,1)
	if not check and res then
		check=true
	end
	if check and Duel.GetTargetParam()==1 and tc:IsRelateToChain() and aux.NegateMonsterFilter(tc) and tc:IsCanBeDisabledByEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Negate(tc,e,RESET_PHASE|PHASE_END,false,false,TYPE_MONSTER)
	end
end
function s.gcheck(g)
	local c1,c2=g:GetFirst(),g:GetNext()
	return c1:GetFusionAttribute()&c2:GetFusionAttribute()>0 and c1:IsRace(c2:GetRace()) and c1:IsAttack(c2:GetAttack())
end
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if not mg or #mg<2 then
		e:GetLabelObject():SetLabel(0)
		return
	end
	if mg:CheckSubGroup(s.gcheck,2,2) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end