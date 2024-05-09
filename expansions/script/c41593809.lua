--created by LeonDuvall, coded by Lyris
--Skypiercer Zeppelin
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.mfilter,2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_F)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCondition(s.desbcon)
	e1:SetTarget(s.dbtg)
	e1:SetOperation(s.dbop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCondition(s.decon)
	e2:SetTarget(s.detg)
	e2:SetOperation(s.deop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE)
end
function s.dbcon(e,_,eg)
	return eg:GetFirst()==e:GetHandler()
end
function s.dbtg(e,_,_,_,_,_,_,_,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local g=Group.CreateGroup(c,c:GetBattleTarget())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function s.dbop(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not (c:IsRelateToEffect(e) and bc:IsRelateToBattle()) then return end
	Duel.Destroy(Group.CreateGroup(c,bc),REASON_EFFECT)
end
function s.decon(e,_,_,_,ev,re)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and g and g:IsContains(c)
end
function s.detg(e,_,eg,_,_,re,_,_,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsDestructable() and rc:IsRelateToEffect(re) and rc:IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg+c,2,0,0)
	end
end
function s.deop(e,_,eg,_,_,re)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if not (c:IsRelateToEffect(e) and rc:IsRelateToEffect(re)) then return end
	Duel.Destroy(eg+c,REASON_EFFECT)
end
function s.filter(c,e,tp)
	return s.mfilter(c) and c:IsLevelAbove(1) and c:IsCanBeEffectTarget(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gchk(g,e,tp,sg)
	return #g<2 or sg:IsExists(s.sfilter,1,nil,e,tp,g)
end
function s.sfilter(c,e,tp,g)
	local mt=getmetatable(c)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and mt and mt.material_minct>1 and mt.material_maxct>1
		and Duel.CheckXyzMaterial(c,mt.material_filter,g:GetSum(Card.GetOriginalLevel),2,2,g)
		and not g:IsExists(aux.NOT(Card.IsCanBeXyzMaterial),1,nil,c)
end
function s.sptg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local sg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and g:CheckSubGroup(s.gchk,2,2,e,tp,sg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local mg=g:SelectSubGroup(tp,s.gchk,false,2,2,e,tp,sg)
	Duel.SetTargetCard(mg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,2,0,0)
end
function s.spop(e,tp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	local lv=g:GetSum(Card.GetOriginalLevel)
	local ct=0
	for tc in aux.Next(g) do if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(lv)
		tc:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3,true)
		ct=ct+1
	end end
	Duel.SpecialSummonComplete()
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(aux.TargetBoolFunction(aux.NOT(s.mfilter)))
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
	Duel.AdjustAll()
	local sg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil):Filter(s.sfilter,nil,e,tp,g)
	if ct~=2 or g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)~=2 or #sg<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	Duel.BreakEffect()
	Duel.XyzSummon(tp,sc,g)
end
