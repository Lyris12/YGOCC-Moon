--MMS - Seguace
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ssproc
	c:SSProc(0,nil,LOCATION_HAND,true,s.spcon)
	--attack limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	--change level
	c:Ignition(1,{0,CATEGORY_LVCHANGE},nil,LOCATION_GRAVE,nil,
		aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),
		aux.bfgcost,
		s.lvtg,
		s.lvop
	)
end
function s.spcon(e,c,tp)
	return Duel.IsExistingMatchingCard(aux.Faceup(Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0xd71)
end

function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0xd71) and c~=e:GetHandler()
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd71)
end
function s.lvfilter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0xd71) and c:HasLevel() and (not lv or not c:IsLevel(lv))
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	local list={}
	for lv=1,6 do
		if not g:IsExists(aux.NOT(Card.IsLevel),1,nil,lv) then
			table.insert(list,lv)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,6,table.unpack(list))
	Duel.SetTargetParam(lv)
	Duel.SetCustomOperationInfo(0,CATEGORY_LVCHANGE,nil,1,tp,LOCATION_MZONE,lv)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetTargetParam()
	if not lv then return end
	local g=Duel.Select(HINTMSG_FACEUP,false,tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,lv)
	if #g>0 then
		Duel.HintSelection(g)
		g:GetFirst():ChangeLevel(lv,true,e:GetHandler())
	end
end