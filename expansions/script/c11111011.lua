--Roland Zorael's' Skydianborn Gears
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:HOPT(true)
	c:RegisterEffect(e0)
	--Activate(destroy)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.cncon1)
	e1:SetCost(aux.LabelCost)
	e1:SetTarget(s.cntg(false))
	e1:SetOperation(s.cnop(false))
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:Desc(2)
	e1x:SetCondition(s.cncon2)
	e1x:SetTarget(s.cntg(true))
	e1x:SetOperation(s.cnop(true))
	c:RegisterEffect(e1x)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,RELEVANT_TIMINGS)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
--Activate (DESTROY)
--filters
function s.cncfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
		
---------
function s.cncon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cncfilter,1,nil) and eg:IsExists(Card.IsSetCard,1,nil,0x223)
end
function s.cncon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cncfilter,1,nil) and not eg:IsExists(Card.IsSetCard,1,nil,0x223)
end
function s.cntg(selfdestroy)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local c=e:GetHandler()
		local exc = selfdestroy and c or nil
		if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
		if chk==0 then
			if e:GetLabel()~=1 then return false end
			e:SetLabel(0)
			return not e:IsHasType(EFFECT_TYPE_ACTIVATE) or Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc)
		end
		e:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
		if selfdestroy and c:IsRelateToChain() then
			g:AddCard(c)
		end
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
end
function s.cnop(selfdestroy)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local tc=Duel.GetFirstTarget()
				if tc:IsRelateToChain() and tc:IsFaceup() and Duel.Destroy(tc,REASON_EFFECT)>0 and selfdestroy then
					local c=e:GetHandler()
					if c:IsRelateToChain() then
						if c:IsDestructable(e) then
							Duel.BreakEffect()
						end
						Duel.Destroy(e:GetHandler(),REASON_EFFECT)
					end
				end
			end
end

function s.filter(c,tp)
	local eqc=c:GetEquipTarget()
	return eqc and c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSetCard(0xd0a2) and not c:IsForbidden()
		and Duel.GetMatchingGroupCount(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,eqc,c)>0
end
function s.eqfilter(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_EQUIP)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sg=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetEquipTarget(),tc)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.Equip(tp,tc,sg:GetFirst())
		end
	end
end