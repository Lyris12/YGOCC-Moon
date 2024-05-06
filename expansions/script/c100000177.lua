--[[
Cursilver Lord Spreader of Despair
Signore Sciagurargento Disseminatore di Disperazione
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) by Tributing 2 monsters, including a DARK monster.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--This card is unaffected by the effects of "Cursilver Sword of Endless Pain".
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--While this card is equipped with "Cursilver Sword of Endless Pain", it gains 600 ATK/DEF, also it cannot be destroyed by card effects.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.eqcon)
	e3:SetValue(600)
	c:RegisterEffect(e3)
	e3:UpdateDefenseClone(c)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetCondition(s.eqcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--[[Once per turn (Quick Effect): You can Tribute 1 other card; destroy 1 card on the field, and if you do, if the destroyed card was a monster,
	inflict damage to your opponent equal to that monster's original Level x 100.]]
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:OPT()
	e5:SetRelevantTimings()
	e5:SetCost(s.descost)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
--E1
function s.fselect(g,tp)
	return g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK) and aux.mzctcheckrel(g,tp)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return rg:CheckSubGroup(s.fselect,2,2,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=rg:SelectSubGroup(tp,s.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end

--E2
function s.efilter(e,te)
	return te:GetHandler():IsCode(id+1)
end

--E3 E4
function s.eqcon(e)
	return e:GetHandler():GetEquipGroup():IsExists(aux.FaceupFilter(Card.IsCode,id+1),1,nil)
end

--E5
function s.cfilter(c,tp)
	return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c)
end
function s.desfilter(c,tc)
	return c:GetEquipTarget()~=tc
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.CheckReleaseGroup(tp,s.cfilter,1,c,tp) or Duel.IsExistingMatchingCard(Card.IsReleasable,tp,LOCATION_SZONE,0,1,c)
	end
	local sg
	local b1=Duel.CheckReleaseGroup(tp,s.cfilter,1,c,tp)
	local b2=Duel.IsExistingMatchingCard(Card.IsReleasable,tp,LOCATION_SZONE,0,1,c)
	local opt=aux.Option(tp,id,2,b1,b2)
	if opt==1 then
		Duel.HintMessage(tp,HINTMSG_RELEASE)
		sg=Duel.SelectMatchingCard(tp,Card.IsReleasable,tp,LOCATION_SZONE,0,1,1,c)
	else
		sg=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,c,tp)
	end
	Duel.Release(sg,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	local g=Duel.GetFieldGroup(0,LOCATION_ONFIELD,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsPreviousLocation(LOCATION_MZONE) and tc:GetOriginalType()&TYPE_MONSTER>0 then
			local lv=tc:GetOriginalLevel()
			if not lv or lv<=0 then return end
			Duel.Damage(1-tp,lv*100,REASON_EFFECT)
		end
	end
end