--MMS - Commerciante
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--search
	c:Ignition(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,LOCATION_HAND,true,
		nil,
		aux.DiscardSelfCost,
		aux.SearchTarget(s.thfilter),
		aux.SearchOperation(s.thfilter)
	)
	--draw
	c:SummonedTrigger(false,false,true,false,1,CATEGORY_DRAW,EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET,true,
		s.drawcon,
		nil,
		aux.DrawTarget(2),
		s.drawop
	)
end
function s.thfilter(c)
	return (c:IsSetCard(0xd71) and c:IsST(TYPE_CONTINUOUS)) or c:IsCode(19905912)
end

function s.drawcon(e)
	return not e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetLabel(p)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,p)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.splimit(e,c)
	local p=e:GetLabel()
	return c:IsLocation(LOCATION_EXTRA) and c:IsControler(p) and not c:IsSetCard(0xd71)
end