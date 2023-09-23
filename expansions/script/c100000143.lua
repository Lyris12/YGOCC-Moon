--Pastglory Compiler
--Compilatore Gloriapassata
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,s.ffilter,2,99,true)
	--[[If this card leaves the field, and there are 2 or more monster card types (Fusion, Synchro, Xyz, or Bigbang) among the cards in the GYs:
	You can Special Summon 1 "Pastglory Compiler" from your Extra Deck. (This is treated as a Fusion Summon.)]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--[[If this card is Fusion Summoned: You can activate 1 or both of these effects (simultaneously).
	● This card gains 500 ATK or DEF.
	● Destroy 1 monster on the field with the same Attribute as a material(s) used for this card.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetFunctions(aux.FusionSummonedCond,nil,s.target,s.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetLabel(0)
	e3:SetValue(s.matcheck)
	c:RegisterEffect(e3)
	e2:SetLabelObject(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(aux.FusionSummonedCond)
	e4:SetOperation(s.regop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
function s.checkfilter(c,sg)
	return sg:FilterCount(Card.IsRace,c,c:GetRace())~=1
end
function s.ffilter(c,fc,sub,mg,sg)
	local res=false
	if not c:IsFusionType(TYPE_MONSTER) or (mg and not mg:IsExists(Card.IsRace,1,c,c:GetRace())) then return false end
	if not sg then return true end
	if sg:FilterCount(Card.IsRace,c,c:GetRace())>1 then return false end
	if mg and #sg<#mg then return true end
	return not sg:IsExists(s.checkfilter,1,nil,sg)
end

--E1
function s.classfunction(c)
	return c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_BIGBANG)
end
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:CheckFusionMaterial() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.Group(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil):GetClassCount(s.classfunction)
		return ct>=2 and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
	end
end

--E2
function s.matcheck(e,c)
	local g=c:GetMaterial()
	local att=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		att=(att|tc:GetOriginalAttribute())
	end
	e:SetLabel(att)
end
function s.filter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local attr=e:GetLabelObject():GetLabel()
	local b1 = (c:HasAttack() or c:HasDefense())
	local b2 = (attr~=0 and Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,attr))
	local both = b1 and b2
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,2,b1,b2,both)+1
	e:SetLabel(opt)
	if opt&1==1 then
		e:SetCategory(CATEGORIES_ATKDEF)
		local p,loc=c:GetControler(),c:GetLocation()
		Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,c,1,p,loc,500)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DEFCHANGE,c,1,p,loc,500)
	end
	if opt&2==2 then
		e:SetCategory(e:GetCategory()|CATEGORY_DESTROY)
		local g=Duel.Group(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,attr)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,PLAYER_ALL,LOCATION_MZONE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=e:GetLabel()
	if opt&1==1 and c:IsRelateToChain() and c:IsFaceup() then
		local choice=aux.Option(tp,nil,nil,{c:HasAttack(),nil,STRING_ATK},{c:HasDefense(),nil,STRING_DEF})
		local f = (choice==0) and Card.UpdateATK or Card.UpdateDEF
		f(c,500,true,c)
	end
	if opt&2==2 then
		local attr=e:GetLabelObject():GetLabel()
		if attr==0 then return end
		local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,attr)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local attr=e:GetLabelObject():GetLabel()
	if attr==0 then return end
	for _,str in aux.GetAttributeStrings(attr) do
		c:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,str)
	end
end